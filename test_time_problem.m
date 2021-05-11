%% MESH PARAMETERS
shared_data.Nxy=51;
shared_data.L1=10; shared_data.L2=10;
shared_data.frac_start_end={[0.1 0.2], [0.7 0.8]
                [0.3 0.5], [0.9 0.5]};
            
%% ELAST PARAMETERS
elast_problem.sumbdomains_FETI=20;
elast_problem.par_tloustka_trhliny = 1e-4;
elast_problem.par_Lame_lambda = 1e9;
elast_problem.par_Lame_mu = 1e9;

%% HYDRO PARAMETERS
hydro_problem.cislo_ulohy=4;
hydro_problem.n_windows=8;
hydro_problem.DIRICHLET_PRESSURE=1e6; % puvodne1e5; % 
hydro_problem.hydro_model=0;
hydro_problem.alfa_inter_const=1e-8;
par_permeabilita_trhliny = 1e-9;
par_dynamicka_viskozita = 1/897;
par_permeabilita_horniny = 1e-15*par_dynamicka_viskozita;%permeabilita
hydro_problem.mat_omega_const=par_permeabilita_horniny/par_dynamicka_viskozita;%hydraulicka konduktivita
hydro_problem.mat_frac_const=1e-6;%1/(12*par_dynamicka_viskozita);

%% OTHER INPUT PARAMETERS
par_storativity = 0.1449e-9;
hydro_problem.const_cs_domain = (1/ 2e8)+ 5.8e-7*0.2;
hydro_problem.const_cs_fracture = 5.8e-7*1e-4;
hydro_problem.par_BiotWillis = 1;
hydro_problem.par_a0 = 1e-6;
hydro_problem.const_delta_t = 1e6;
%% SOLVER PARAMETERS
SMALSE_params.rel=1.0e-4;
SMALSE_params.rho0=1;
SMALSE_params.betarho=2;
SMALSE_params.Gama = 1;
SMALSE_params.M_start=0.5;
SMALSE_params.tol_to_update=5e3;
SMALSE_params.maxiter_cg = 600;
SMALSE_params.type='m';
SMALSE_params.print=false;
SMALSE_params.print_couple=true;
SMALSE_params.coupling_iter=2000;
SMALSE_params.eps_coupling=1e-4;

[elast_problem,shared_data] = elast_preparation(elast_problem,shared_data);
hydro_problem = hydro_preparation( hydro_problem,shared_data );
initial_aperture = 1e-4*ones(hydro_problem.no_fractures,1);
[elast_problem] = smalse.SMALSE_prepare(elast_problem);

data.hydro_problem=hydro_problem;
data.elast_problem=elast_problem;
data.SMALSE_params=SMALSE_params;
% data si můžeš uložit a loadnout

G=@(u,data)coup.time_solver(data.hydro_problem,data.elast_problem,data.SMALSE_params,u);

u=[-7; -5];

tic;
[Q,D] = G(u,data);
toc

figure; plot(Q(:,2:end))
figure; imagesc(D)
