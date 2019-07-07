# Test_oracle
To intall the components :

@intall 


-- To list the plan of the house (parameter number of the house)
SELECT *
FROM TABLE(pkg_house_mgmt.fnc_Get_list_plan(1));

-- to create a new house
begin
   pkg_house_mgmt.prc_CreateNewHouse;
end;

-- To modify the charge of a phase (only child phases can be modified, parent phases are modified by the program)
begin
   pkg_house_mgmt.prc_Modify_phase_charges(5,15);
end;

-- To modify the duration of a phase (only child phases can be modified, parent phases are modified by the program)
begin
   pkg_house_mgmt.prc_Modify_phase_duration(5,-10);
end;

begin
   pkg_house_mgmt.prc_Modify_phase_duration(5,-10);
end;

-- to modify the installments of the phase (three installments maximum)
begin
   pkg_house_mgmt.prc_Modify_installments(2,50,50);
end;

begin
   pkg_house_mgmt.prc_Modify_installments(14,50,50);
end;
