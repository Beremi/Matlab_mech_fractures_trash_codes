function [ Q,D,iter,hydro_change ] = frac4_solve( params,data )
%4FRAC_SOLVE Summary of this function goes here
%   Detailed explanation goes here

[Q1,D1,PRESSURE,ugrad,iter1,x_elast,response_D,hydro_change1] = coup.coupled_solver_adaptive...
    (data.uloha1.hydro_problem,data.uloha1.elast_problem,data.uloha1.SMALSE_params,params);
[Q2,D2,PRESSURE,ugrad,iter2,x_elast,response_D,hydro_change2] = coup.coupled_solver_adaptive...
    (data.uloha2.hydro_problem,data.uloha2.elast_problem,data.uloha2.SMALSE_params,params);
[Q3,D3,PRESSURE,ugrad,iter3,x_elast,response_D,hydro_change3] = coup.coupled_solver_adaptive...
    (data.uloha3.hydro_problem,data.uloha3.elast_problem,data.uloha3.SMALSE_params,params);
[Q4,D4,PRESSURE,ugrad,iter4,x_elast,response_D,hydro_change4] = coup.coupled_solver_adaptive...
    (data.uloha4.hydro_problem,data.uloha4.elast_problem,data.uloha4.SMALSE_params,params);
Q=[Q1(2:end) Q2(2:end) Q3(2:end) Q4(2:end)];
D=[cell2mat(D1)' cell2mat(D2)' cell2mat(D3)' cell2mat(D4)'];
iter=[iter1 iter2 iter3 iter4];
hydro_change{1}=hydro_change1;
hydro_change{2}=hydro_change2;
hydro_change{3}=hydro_change3;
hydro_change{4}=hydro_change4;
end

