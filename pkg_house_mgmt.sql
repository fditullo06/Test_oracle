create or replace package PKG_HOUSE_MGMT as

        function  fnc_Get_list_plan(p_house_id number) return t_plan_tab
        pipelined;
       
        procedure prc_CreateNewHouse;
        
        procedure prc_Modify_phase_charges(p_phase_id number, p_percent number); 

        procedure prc_Modify_phase_duration(p_phase_id number, p_days number); 
        
        procedure prc_Modify_installments(p_phase_id number, p_inst1 number, p_inst2 number default null, p_inst3 number default null); 
        

end PKG_HOUSE_MGMT;
/

create or replace package body PKG_HOUSE_MGMT as

FUNCTION fnc_Get_list_plan(p_house_id number)
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
                    select * from
                    (
                      SELECT LPAD(' ',4*(LEVEL-1)) ||tphase.phase_code phase_code,
                      tphase.phase_duration,
                      tplan.plan_id,
                      tphase.phase_id,
                      tplan.start_date,
                      tplan.end_date,
                      tphase.charges*nvl(install_pct,1) charges,
                      decode(install_pct, null, null, to_char(tbi.install_pct*100)||'%') intall_pct,
                      case
                      when tplan.parent_phase_id is null then
                          (select plan_id from tb_house where house_id = p_house_id)
                      else
                          ROW_NUMBER() OVER (PARTITION BY tplan.plan_id,tphase.phase_id,install_id,tbi.install_pct ORDER BY tplan.plan_id,tphase.phase_id,install_id,tbi.install_pct)
                      end row_id
                      FROM tb_plan tplan inner join tb_phase tphase on tplan.phase_id = tphase.phase_id
                      left outer join tb_installment tbi on tphase.phase_id = tbi.phase_id
                      where tplan.plan_id = (select plan_id from tb_house where house_id = p_house_id)
                      START WITH tplan.parent_phase_id is null
                      CONNECT BY PRIOR tplan.phase_id = tplan.parent_phase_id
                      order by phase_id
                      ) where row_id = (select plan_id from tb_house where house_id = p_house_id)
                    ) 
                    select  0 phase_id, house_code, total_duration, start_date, end_date, total_charges, install from thouse
                    union all
                    select 
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
                    charges,
                    /*
                    case 
                      when  phase_code = lag(tabplan.phase_code, 1) over (order by phase_id) then
                        null
                      else
                        charges
                    end charges,
                    */
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

procedure prc_CreateNewHouse 
is
type row_plan is record
(
   t_plan_id number,
   t_phase_id number,
   t_parent_phase_id number,
   t_start_date date,
   t_end_date date,
   t_duration number
);

TYPE tab_plan is table of row_plan index by PLS_INTEGER;

tb_p tab_plan;

new_date_start date;
new_id_plan number;

ln_max_house_id number;

begin
    
    select max(house_id) 
    into ln_max_house_id  
    from tb_house;
    
    
    select plan_seq.nextval 
    into new_id_plan
    from dual;
    
    select max(end_date)+1
    into  new_date_start
    from tb_plan pl 
    inner join tb_house ho on pl.plan_id = ho.plan_id
    where ho.house_id = ln_max_house_id;

    select 
    pl.plan_id, 
    pl.phase_id, 
    pl.parent_phase_id, 
    pl.start_date,
    pl.end_date,
    ph.phase_duration
    BULK COLLECT INTO tb_p
    from tb_plan pl 
    inner join tb_house ho on pl.plan_id = ho.plan_id
    inner join tb_phase ph on pl.phase_id = ph.phase_id
    where ho.house_id = ln_max_house_id ;

    FOR i IN 1 .. tb_p.COUNT
    LOOP
  
      tb_p(i).t_plan_id := new_id_plan;
      if tb_p(i).t_phase_id = 1 then
          tb_p(i).t_start_date := new_date_start;
      elsif tb_p(i-1).t_parent_phase_id is null then
          tb_p(i).t_start_date := tb_p(i-1).t_start_date;
      else 
          tb_p(i).t_start_date:=tb_p(i-1).t_end_date+1;
      end if;
      
      tb_p(i).t_end_date := tb_p(i).t_start_date+tb_p(i).t_duration - 1;
   
    END LOOP;

   forall indx IN 1 .. tb_p.COUNT
     insert into TB_PLAN (plan_id, phase_id, parent_phase_id, start_date, end_date) values
     (
      tb_p(indx).t_plan_id, 
      tb_p(indx).t_phase_id, 
      tb_p(indx).t_parent_phase_id, 
      tb_p(indx).t_start_date,
      tb_p(indx).t_end_date
     );

     commit;
     
     insert into TB_HOUSE
     values(
        house_seq.nextval,
        new_id_plan
       );
     
     commit;  
      
exception
  
   when others then
     raise;

end;

procedure prc_Modify_phase_charges(p_phase_id number, p_percent number)
is

p_parent_phase_id number;
is_parent_phase exception;

begin

  begin
   select parent_phase_id 
   into p_parent_phase_id
   from tb_phase where
   phase_id = p_phase_id;
   
   if p_parent_phase_id is null 
   then
   
      raise is_parent_phase;
      
   end if;
   
  exception  
  when no_data_found then
    
     raise no_data_found;
   
  end; 

  
        update TB_PHASE set charges = charges + (charges*(p_percent)/100) 
        where phase_id = p_phase_id;
   

        update TB_PHASE tp1 set charges = 
        (select sum(charges) from TB_PHASE tp2
        where parent_phase_id = p_parent_phase_id
        ) where tp1.phase_id = p_parent_phase_id;

    commit;
    
exception
  
  when is_parent_phase then
    raise_application_error (-20001,'You cannot modify the amount of a parent phase, only of a sub-phase');
    raise;
        
end;

procedure prc_Modify_phase_duration(p_phase_id number, p_days number)
is

p_parent_phase_id number;
e_parent_phase exception;

begin

  begin
   select parent_phase_id 
   into p_parent_phase_id
   from tb_phase where
   phase_id = p_phase_id;
   
   if p_parent_phase_id is null 
   then
   
      raise e_parent_phase;
      
   end if;
   
  exception  
  when no_data_found then
    
     raise no_data_found;
   
  end; 

  
        update TB_PHASE set  phase_duration = phase_duration + p_days 
        where phase_id = p_phase_id;
   

        update TB_PHASE tp1 set phase_duration = 
        (select sum(phase_duration) from TB_PHASE tp2
        where parent_phase_id = p_parent_phase_id
        ) where tp1.phase_id = p_parent_phase_id;

    commit;
    
exception
  
  when e_parent_phase then
    raise_application_error (-20001,'You cannot modify the duration of a parent phase, only of a sub-phase');
    raise;
        
end;

procedure prc_Modify_installments(p_phase_id number, p_inst1 number, p_inst2 number default null, p_inst3 number default null)
is

e_incorrect_repartition exception;
e_parent_phase exception;
p_inst_count number(3);

begin

begin

  begin
   select count(*)
   into p_inst_count
   from tb_installment where
   phase_id = p_phase_id;
 
   if p_inst_count = 0 then
     raise e_parent_phase;
   end if;
 
  exception  
  when no_data_found then
     raise no_data_found;
  end; 


   if  nvl(p_inst1,0) + nvl(p_inst2,0) + nvl(p_inst3,0) <> 100
     then
     
        raise e_incorrect_repartition;
        
     end if;
   end;

   delete from tb_installment where phase_id = p_phase_id;

   if p_inst1 is not null then
     insert into tb_installment(phase_id,install_pct) values(p_phase_id,p_inst1/100);
   end if;  
     
   if p_inst2 is not null then
     insert into tb_installment(phase_id,install_pct) values(p_phase_id,p_inst2/100);
   end if;  
   
   if p_inst3 is not null then
     insert into tb_installment(phase_id,install_pct) values(p_phase_id,p_inst3/100);
   end if;  

exception
  
  when e_incorrect_repartition then
    raise_application_error (-20001,'the sum of the repartitions is <> from one hundred');
    raise;

  when e_parent_phase then
    raise_application_error (-20001,'phase not found, probably a parent phase, you can modify only child phases');
    raise;

end;

end PKG_HOUSE_MGMT;
/
