function [ Q,D,iter,hydro_change ] = fracone_solve( params,uloha1 )
%4FRAC_SOLVE Summary of this function goes here
%   Detailed explanation goes here

[Q1,D1,PRESSURE,ugrad,iter1,x_elast,response_D,hydro_change1] = coup.coupled_solver_adaptive...
    (uloha1.hydro_problem,uloha1.elast_problem,uloha1.SMALSE_params,params);
Q=[Q1(2:end)];
D=[cell2mat(D1)' ];
iter=[iter1];
hydro_change{1}=hydro_change1;
end

