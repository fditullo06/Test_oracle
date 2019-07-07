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

