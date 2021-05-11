
data=load('data_4frac.mat');

n=10000;
all_params=randn(n,4)/3+[-6 -6.5 -5.8 -7];
%all_params(1,:)=[-6 -6.5 -5.8 -7];
all_Q=zeros(n,16);
all_D=zeros(n,384);
all_iter=zeros(n,4);
all_hydro_change=cell(n,1);
tic
parfor i=1:n
    params=all_params(i,:);
    [ Q,D,iter,hydro_change ] = frac4_solve( params,data );
    all_D(i,:)=D;
    all_Q(i,:)=Q;
    all_iter(i,:)=iter;
    all_hydro_change{i}=hydro_change;
    fprintf('%IT:%d  -%d-%d-%d-%d \n',i,iter(1),iter(2),iter(3),iter(4));
end
toc