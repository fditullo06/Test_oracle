-- Create the types to support the table function.

DROP TYPE t_plan_tab;
DROP TYPE t_plan_row;

CREATE TYPE t_plan_row AS OBJECT (
  p_phase           varchar2(20),
  p_duration        number,
  p_start_date      date,
  p_end_date        date,
  p_charge          number(12,2),
  p_installment     varchar2(5)
);
/

CREATE TYPE t_plan_tab IS TABLE OF t_plan_row;
/


CREATE OR REPLACE FUNCTION fnc_Get_list_plan(p_house_id number)
  RETURN t_plan_tab
  PIPELINED
AS
BEGIN

    FOR v_Rec IN (with thouse as
                    (
                      select
                      house_id,
                      plan_id,
                      'PLAN OF HOUSE'||HOUSE_ID HOUSE_CODE,
                      (select sum(phase_duration) total_duration from 
                      tb_phase tbph inner join tb_plan tbp 
                      on tbph.phase_id = tbp.phase_id and
                      tbp.parent_phase_id is null
                      and tbp.plan_id = (select plan_id from tb_house where house_id = p_house_id)) total_duration,
                      (select min(start_date) 
                      from TB_PLAN pl inner join TB_HOUSE h
                      on pl.PLAN_ID = h.PLAN_ID
                      where  pl.plan_id = (select plan_id from tb_house where house_id = p_house_id)) start_date,
                     (select max(end_date) 
                      from TB_PLAN pl inner join TB_HOUSE h
                      on pl.PLAN_ID = h.PLAN_ID
                      and pl.plan_id = (select plan_id from tb_house where house_id = p_house_id)) end_date,
                     (select sum(charges)  from 
                      tb_phase tbph inner join tb_plan tbp 
                      on tbph.phase_id = tbp.phase_id and
                      tbp.parent_phase_id is null
                      and tbp.plan_id = (select plan_id from tb_house where house_id = p_house_id)) total_charges, 
                      null install
                      from 
                      tb_house
                      where house_id = p_house_id
                    ),
                    tabplan as
                    (
                    SELECT distinct LPAD(' ',4*(LEVEL-1)) ||tphase.phase_code phase_code,
                    tphase.phase_duration,
                    tplan.plan_id,
                    tphase.phase_id,
                    tplan.start_date,
                    tplan.end_date,
                    tphase.charges,
                    decode(install_pct, null, null, to_char(tbi.install_pct*100)||'%') intall_pct
                    FROM tb_plan tplan inner join tb_phase tphase on tplan.phase_id = tphase.phase_id
                    left outer join tb_installment tbi on tphase.phase_id = tbi.phase_id
                    where tplan.plan_id = (select plan_id from tb_house where house_id = p_house_id)
                    START WITH parent_phase_id is null
                    CONNECT BY PRIOR tplan.phase_id = tplan.parent_phase_id
                    order by phase_id
                    ) 
                    select  0 phase_id, house_code, total_duration, start_date, end_date, total_charges, install from thouse
                    union all
                    select distinct
                    phase_id,
                    case 
                      when phase_code = lag(tabplan.phase_code, 1) over (order by phase_id) then
                        null
                      else
                        phase_code
                    end phase_code,
                    case 
                      when  phase_code = lag(tabplan.phase_code, 1) over (order by phase_id) then
                        null
                      else
                        phase_duration
                    end phase_duration,
                    case 
                      when  phase_code = lag(tabplan.phase_code, 1) over (order by phase_id) then
                        null
                      else
                        start_date
                    end start_date,
                    case 
                      when  phase_code = lag(tabplan.phase_code, 1) over (order by phase_id) then
                        null
                      else
                        end_date
                    end end_date,
                    case 
                      when  phase_code = lag(tabplan.phase_code, 1) over (order by phase_id) then
                        null
                      else
                        charges
                    end charges,
                    tabplan.intall_pct
                    from tabplan inner join tb_house tbh
                    on tabplan.plan_id = tbh.plan_id
                    where tbh.house_id = p_house_id
                    order by 1) 
    LOOP

        PIPE ROW (t_plan_row(v_Rec.house_code, v_Rec.total_duration,v_Rec.start_date,v_Rec.end_date,v_Rec.total_charges,v_Rec.install ));

    END LOOP;

    RETURN;
END;

