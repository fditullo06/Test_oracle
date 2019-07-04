
INSERT ALL
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (1, 'LOT PREPARATION', 7,13112.39)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (2, 'CLEAR LOT', 7,13112.39)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (3, 'FRAMEWORK BUILDING', 105,196685.85)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (4, 'FOUNDATION', 10,18732.30)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (5, 'GROUND FLOOR', 50,93659.55)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (6, 'FIRST FLOOR', 45,84294.00)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (7, 'ROOFING', 45,84294.65)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (8, 'WOODEN FRAME', 20,37465.00)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (9,'TILES LYING', 25,46829.65)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (10,'INTERIOR WORKS', 90,168588.10)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (11,'FLOOR PARQUET', 15,28097.60)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (12,'PAINTING', 10,18731.20)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (13,'KITCHEN', 30,56197.00)
  INTO tb_phase (PHASE_ID, PHASE_CODE,PHASE_DURATION,CHARGES) VALUES (14,'BATHROOM', 35,65562.30)
SELECT * FROM dual;

commit;

INSERT ALL
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (1, 2, 1)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (2, 4, 0.1)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (3, 5, 0.2)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (4, 5, 0.5)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (5, 5, 0.3)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (6, 6, 0.4)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (7, 6, 0.6)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (8, 8, 1)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (9, 9, 0.5)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (10, 9, 0.5)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (11, 11, 1)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (12, 12, 1)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (13, 13, 0.7)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (14, 13, 0.3)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (15, 14, 0.3)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (16, 14, 0.4)
  INTO tb_installment (INSTALL_ID, PHASE_ID, INSTALL_PCT) VALUES (17, 14, 0.3)
SELECT * FROM dual;

commit;

truncate table tb_plan;

INSERT ALL
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 1,null, to_date('01/01/2020','DD/MM/YYYY'),to_date('01/08/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 2,1, to_date('01/01/2020','DD/MM/YYYY'),to_date('01/08/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 3,null, to_date('09/01/2020','DD/MM/YYYY'),to_date('25/04/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 4,3, to_date('09/01/2020','DD/MM/YYYY'),to_date('19/01/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 5,3, to_date('20/01/2020','DD/MM/YYYY'),to_date('10/03/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 6,3, to_date('11/03/2020','DD/MM/YYYY'),to_date('25/04/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 7,null, to_date('26/04/2020','DD/MM/YYYY'),to_date('11/06/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 8,7, to_date('26/04/2020','DD/MM/YYYY'),to_date('16/05/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 9,7, to_date('17/05/2020','DD/MM/YYYY'),to_date('11/06/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 10,null, to_date('12/06/2020','DD/MM/YYYY'),to_date('13/09/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 11,10, to_date('12/06/2020','DD/MM/YYYY'),to_date('27/06/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 12,10, to_date('28/06/2020','DD/MM/YYYY'),to_date('08/07/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 13,10, to_date('09/07/2020','DD/MM/YYYY'),to_date('08/08/2020','DD/MM/YYYY'))
  into tb_plan(PLAN_ID, PHASE_ID, PARENT_PHASE_ID, START_DATE, END_DATE) values (plan_seq.nextval, 14,10, to_date('09/08/2020','DD/MM/YYYY'),to_date('13/09/2020','DD/MM/YYYY'))
select * from dual;


commit;



insert into TB_HOUSE (plan_id) values
(
  (select MAX(plan_id) from tb_plan) 
 );
 
commit;


