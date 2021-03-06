function [Q,D,PRESSURE,ugrad,iter,x_elast,response_D,hydro_change] = coupled_solver_adaptive(hydro_problem,elast_problem,SMALSE_params,params)
par_BiotWillis = hydro_problem.par_BiotWillis;
no_fractures=hydro_problem.no_fractures;
lengths=hydro_problem.lengths;
eps_coupling=SMALSE_params.eps_coupling;
mat_frac=10.^(params);
D = cell(no_fractures,1);
for i=1:no_fractures
    D{i} = 1e-4*ones(lengths(i)-1,1);
end

[~,u_old_single,ugrad,Q,PRESSURE]=coup.hydro_basicStationary(D,hydro_problem,mat_frac);
u_old={u_old_single};
ugrad_all={ugrad};
PRESSURE_all={PRESSURE};
[elast_problem] = feti.assembly_FETI_frac_rhs(elast_problem,PRESSURE,-ugrad*par_BiotWillis);
[D,elast_problem,x_elast] = smalse.SMALSE_solver_new(elast_problem,SMALSE_params);
D_all={D};

shifts=[0];
cas_krok=[0];
hydro_change=[0];
alphas=[0];
trasholds=[0];
smooth_distances=[0];
D_log_distance_all=[0];

response_D = cell2mat(D);
response_D_smooth=cell2mat(D);
trashold=1;
trashold_D=0.5;
alpha=1;
beta1=10;
beta2=8;

i=1;
iter=0;
tmp_prec=1;
hydro_problem.const_delta_t=1e3;
while iter<=SMALSE_params.coupling_iter
    
    i=i+1;
    iter=iter+1;
    
    [~,u0_,ugrad,PRESSURE,~]=coup.hydro_basicSemiEvolution(D_all{i-1},hydro_problem,u_old{i-1},mat_frac);
    shift=hydro_shift(ugrad_all{i-1},ugrad);
    shifts(i)=shift;
    
    if shift<trashold*0.9
        hydro_problem.const_delta_t=min(hydro_problem.const_delta_t*10,1e6/max(trashold,trashold_D));
    end
    
    while shift>=trashold
        hydro_problem.const_delta_t=hydro_problem.const_delta_t/2;
        [~,u0_,ugrad,PRESSURE,~]=coup.hydro_basicSemiEvolution(D_all{i-1},hydro_problem,u_old{i-1},mat_frac);
        shift=hydro_shift(ugrad_all{i-1},ugrad);
        %fprintf('    Correction: Shift: %d, delta T: %d \n',shift,hydro_problem.const_delta_t)
    end
    
    cas_krok(i)=hydro_problem.const_delta_t;
   
    u_old{i} = u0_;
    ugrad_all{i}=ugrad;
    PRESSURE_all{i}=PRESSURE;
    
    
    [elast_problem] = feti.assembly_FETI_frac_rhs(elast_problem,PRESSURE_all{i},-ugrad_all{i}*par_BiotWillis);
    [D,elast_problem,x_elast,ncg] = smalse.SMALSE_solver_new(elast_problem,SMALSE_params);
    response_D(:,i) =cell2mat(D);
    
    if ncg<200
        SMALSE_params.rel=max(SMALSE_params.rel*0.5,1e-12);
    end
    
    [~,~,ugrad_stationary,Q,~]=coup.hydro_basicStationary(D,hydro_problem,mat_frac);
    sta_dist=hydro_shift(ugrad_all{i},ugrad_stationary);
    hydro_change(i)=sta_dist;
    %fprintf('  Stationary distance: %d',sta_dist)

    
    if iter>2
        alpha=min(trashold_D/mech_shift(response_D_smooth(:,i-1),response_D(:,i)),0.9);
    end
    
    
    D=smooth_D(D_all{i-1},D,alpha);
    D_all{i}=D;
    response_D_smooth(:,i)=cell2mat(D);
    
    smooth_distance=mech_shift(response_D_smooth(:,i-1),response_D_smooth(:,i));
    smooth_distances(i)=smooth_distance;
    
    
    D_log_distance_loc=mech_shift(response_D(:,i-1),response_D(:,i));
    D_log_distance_all(i)=D_log_distance_loc;
    
   % fprintf('--- D_now: %d, alpha: %d beta1: %d beta2 %d',D_log_distance_loc,alpha,beta1,beta2)
    
    
    alphas(i)=alpha;
    trasholds(i)=trashold;
    %trashold=max(exp(log(trashold)*0.5+(log(sta_dist))*0.5),1e-6);
    
        % fprintf('  IT: %d ,stadist: %d, delta T: %d, alpha: %d, Ddist: %d \n',i,sta_dist,hydro_problem.const_delta_t,alpha,D_log_distance_loc)
    if iter>5
        trashold_D=max(exp(log(trashold_D)*0.9+log(min(D_log_distance_loc/alpha,1)/beta1)*0.1));
        if D_log_distance_loc>1.2*mech_shift(response_D(:,i-2),response_D(:,i))
            trashold_D=trashold_D*0.5;
        end
    end
    
   % fprintf('\n')
    if sta_dist/min(hydro_problem.const_delta_t,1)<eps_coupling && (D_log_distance_loc)<0.1
        break
    end
    
    trashold=max(exp(log(trashold)*0.75+(log(sta_dist/beta2))*0.25),5e-3);
    trashold_Ds(i)=trashold_D;
    if D_log_distance_loc<1e-2
        beta1=1;
    end
    if D_log_distance_loc<1e-3
        beta1=0.01;
    end     
end

    figure(135)
    trisurf(hydro_problem.ELEMENTS,hydro_problem.POINTS(:,1),hydro_problem.POINTS(:,2),u0_(1:length(hydro_problem.POINTS)),'LineStyle','none');
    plot_trhliny(  )
    caxis([0,1e6])
    colormap jet(1000)
    colorbar
    view(2)
    [~] = elasticity_divergence(elast_problem,x_elast,1);
    plot_trhliny(  )
    drawnow


% fprintf('  IT: %d ,stadist: %d, delta T: %d, thashold: %d, trasholdD: %d \n',i,sta_dist,hydro_problem.const_delta_t,trashold,trashold_D)
% % fprintf('iterations: %d\n',i);
% % % figure
% % % plot(time_change)
% % % figure
% % % plot(D_all_dist)
% % % hold on
% % % plot(D_all_old_dist)
% % 
figure
hold on
yyaxis left
plot(hydro_change)
plot(D_log_distance_all)
plot(alphas)
set(gca,'YScale','log')
yyaxis right
plot(cas_krok)
set(gca,'YScale','log')
%plot(betas1)
%plot(betas2)
% set(gca,'YScale','log')
% 
% 
% figure
% plot(shifts)
% hold on
% plot(smooth_distances)
% set(gca,'YScale','log')
% 
figure
imagesc(log10(response_D))
% iter=i;
% 
 %figure
 %trisurf(hydro_problem.ELEMENTS,hydro_problem.POINTS(:,1),hydro_problem.POINTS(:,2),u0_(1:length(hydro_problem.POINTS)),'LineStyle','none');
end

function shift=hydro_shift(u_old,u_new)
shift=sort(abs(u_old(:)-u_new(:)));%/max(abs(u_new(:)));
shift=max(shift)/1e6;%shift(ceil(end*0.95));
end

function shift=mech_shift(u_old,u_new)
shift=sort(abs(log(u_new)-log(u_old)));
shift=max(shift);%shift(ceil(end*0.95));
end

function D=smooth_D(D_old,D,alpha)
for j=1:length(D)
    D{j}=exp((log(max(D{j},1e-10))*alpha+(1-alpha)*log(max(D_old{j},1e-10))));
end
end