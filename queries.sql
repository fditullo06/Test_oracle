
--create or replace view VW_HOUSE as

with thouse as
(
  select
  house_id,
  plan_id,
  'PLAN OF HOUSE'||HOUSE_ID HOUSE_CODE,
  (select sum(phase_duration) total_duration from 
  tb_phase tbph inner join tb_plan tbp 
  on tbph.phase_id = tbp.phase_id and
  tbp.parent_phase_id is null) total_duration,
  (select min(start_date) 
  from TB_PLAN pl inner join TB_HOUSE h
  on pl.PLAN_ID = h.PLAN_ID) start_date,
 (select max(end_date) 
  from TB_PLAN pl inner join TB_HOUSE h
  on pl.PLAN_ID = h.PLAN_ID) end_date,
 (select sum(charges)  from 
  tb_phase tbph inner join tb_plan tbp 
  on tbph.phase_id = tbp.phase_id and
  tbp.parent_phase_id is null) total_charges, 
  null install
  from 
  tb_house
  where house_id = :P_HOUSE_ID
),
tabplan as
(
SELECT LPAD(' ',4*(LEVEL-1)) ||tphase.phase_code phase_code,
tphase.phase_duration,
tplan.plan_id,
tphase.phase_id,
tplan.start_date,
tplan.end_date,
tphase.charges,
decode(install_pct, null, null, to_char(tbi.install_pct*100)||'%') intall_pct
FROM tb_plan tplan inner join tb_phase tphase on tplan.phase_id = tphase.phase_id
left outer join tb_installment tbi on tphase.phase_id = tbi.phase_id
START WITH parent_phase_id is null
CONNECT BY PRIOR tplan.phase_id = tplan.parent_phase_id
) 
select house_code, total_duration, start_date, end_date, total_charges,install from thouse
union all
select 
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
on tabplan.plan_id = tbh.plan_id;


SELECT *
FROM TABLE(fnc_Get_list_plan(1));







