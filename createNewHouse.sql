create or replace procedure CreateNewHouse(pn_house_id number) 
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

begin
    
    select plan_seq.nextval 
    into new_id_plan
    from dual;
    
    select max(end_date)+1
    into  new_date_start
    from tb_plan pl 
    inner join tb_house ho on pl.plan_id = ho.plan_id
    where ho.house_id = pn_house_id;

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
    where ho.house_id = pn_house_id;

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

end;