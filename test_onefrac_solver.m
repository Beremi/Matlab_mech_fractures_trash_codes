
data=load('u2_onef.mat');
data.SMALSE_params.eps_coupling=1e-4;
n=80*5;
all_params=linspace(-9,-5,n);
%all_params(1,:)=[-6 -6.5 -5.8 -7];
all_Q=zeros(n,4);
all_D=zeros(n,80);
all_iter=zeros(n,1);
all_hydro_change=cell(n,1);
tic
parfor i=1:n
    params=all_params(i);
    [ Q,D,iter,hydro_change ] = fracone_solve( params,data );
    all_D(i,:)=D;
    all_Q(i,:)=Q;
    all_iter(i,:)=iter;
    all_hydro_change{i}=hydro_change;
    fprintf('%IT:%d  %d \n',i,iter(1));
end
toc