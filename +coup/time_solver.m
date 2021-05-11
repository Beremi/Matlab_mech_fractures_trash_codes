%function [Q,D,PRESSURE,ugrad,iter,x_elast,response_D,hydro_change] = time_solver(hydro_problem,elast_problem,SMALSE_params,params)
function [Q,response_D] = time_solver(hydro_problem,elast_problem,SMALSE_params,params)
par_BiotWillis = hydro_problem.par_BiotWillis;
no_fractures=hydro_problem.no_fractures;
lengths=hydro_problem.lengths;
mat_frac=10.^(params);
D = cell(no_fractures,1);
for i=1:no_fractures
    D{i} = 1e-4*ones(lengths(i)-1,1);
end

[~,u_old_single,ugrad,Q,PRESSURE]=coup.hydro_basicStationary(D,hydro_problem,mat_frac);
u_old_single(:)=0;
u_old={u_old_single};
ugrad_all={ugrad};
PRESSURE_all={PRESSURE};
% [elast_problem] = feti.assembly_FETI_frac_rhs(elast_problem,PRESSURE,-ugrad*par_BiotWillis);
% [D,elast_problem,x_elast] = smalse.SMALSE_solver_new(elast_problem,SMALSE_params);
[divergence{1}] = elasticity_divergence(elast_problem,zeros(24506,1),0);
D_all={D};

shifts=[0];
cas_krok=[0];
hydro_change=[0];
alphas=[0];

smooth_distances=[0];
D_log_distance_all=[0];

response_D = cell2mat(D);
response_D_smooth=cell2mat(D);
alpha=0.5;
plotting_on=false;

i=1;
iter=0;
%figure(135)
Q_all=cell(SMALSE_params.coupling_iter,1);
while iter<=SMALSE_params.coupling_iter
    %fprintf('%d\n',i);
    i=i+1;
    iter=iter+1;
    if i<=2
        [~,u0_,ugrad,PRESSURE,~,Q]=coup.hydro_basicSemiEvolution(D_all{i-1},hydro_problem,u_old{i-1},mat_frac);
    else
        diverg_diff=(divergence{i-1}-divergence{i-2})/hydro_problem.const_delta_t;
        [~,u0_,ugrad,PRESSURE,~,Q]=coup.hydro_basicSemiEvolutiondiverg(D_all{i-1},hydro_problem,u_old{i-1},mat_frac,diverg_diff);
    end
    Q_all{iter}=Q;
    shift=hydro_shift(ugrad_all{i-1},ugrad);
    shifts(i)=shift;
    cas_krok(i)=hydro_problem.const_delta_t;
    
    u_old{i} = u0_;
    ugrad_all{i}=ugrad;
    PRESSURE_all{i}=PRESSURE;
    
    
    [elast_problem] = feti.assembly_FETI_frac_rhs(elast_problem,PRESSURE_all{i},-ugrad_all{i}*par_BiotWillis);
    [D,elast_problem,x_elast,ncg] = smalse.SMALSE_solver_new(elast_problem,SMALSE_params);
    response_D(:,i) =cell2mat(D);

%     if ncg<50
%         SMALSE_params.rel=max(SMALSE_params.rel*0.5,1e-12);
%     end
    
    D=smooth_D(D_all{i-1},D,alpha);
    D_all{i}=D;
    response_D_smooth(:,i)=cell2mat(D);
    
    smooth_distance=mech_shift(response_D_smooth(:,i-1),response_D_smooth(:,i));
    smooth_distances(i)=smooth_distance;
    
    D_log_distance_loc=mech_shift(response_D(:,i-1),response_D(:,i));
    D_log_distance_all(i)=D_log_distance_loc;
    
    alphas(i)=alpha;
    if plotting_on
        figure(135)
        trisurf(hydro_problem.ELEMENTS,hydro_problem.POINTS(:,1),hydro_problem.POINTS(:,2),u0_(1:length(hydro_problem.POINTS)),'LineStyle','none');
        plot_trhliny(  )
        caxis([0,1e6])
        colormap jet(1000)
        colorbar
        title(['iter: ' num2str(iter) ' , time: ' num2str(sum(cas_krok))])
        view(2)
        [divergence{i}] = elasticity_divergence(elast_problem,x_elast,1);
        plot_trhliny()
        drawnow
    else
    [divergence{i}] = elasticity_divergence(elast_problem,x_elast,0);
    end
    
end
Q=cell2mat(Q_all);
end

function shift=hydro_shift(u_old,u_new)
shift=sort(abs(u_old(:)-u_new(:)))/1e6;%/max(abs(u_new(:)));
shift=shift(ceil(end*0.95));
end

function shift=mech_shift(u_old,u_new)
shift=sort(abs(log(u_new)-log(u_old)));
shift=shift(ceil(end*0.95));
end

function D=smooth_D(D_old,D,alpha)
for j=1:length(D)
    D{j}=exp((log(max(D{j},1e-10))*alpha+(1-alpha)*log(max(D_old{j},1e-10))));
end
end