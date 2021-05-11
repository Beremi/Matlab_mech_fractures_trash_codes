
data1=load('~/Downloads/10000_4frac.mat');
data2=load('~/Downloads/40000_4frac.mat');
data3=load('~/Downloads/120000_4frac.mat');
data4=load('~/Downloads/600000_4frac.mat');
all_Q=[data1.all_Q;data2.all_Q;data3.all_Q;data4.all_Q];
all_params=[data1.all_params;data2.all_params;data3.all_params;data4.all_params];

sigma_num=1e-11;
sigma_obs=1e-13;
sigma_both=1e-11^2/4+sigma_obs^2;
inv_cov_diag=1/sigma_both;

mask=[2 3 4 5 7 8 9 10 12 13 14 15 17 18 19 20];
param_orig=[-6 -6.5 -5.8 -7];
rng(1)
x=all_Q(1,:)+randn(1,16)*sqrt(sigma_both);

for i=1:77e4
    y=all_Q(i,:);
    likelihood(i)=exp(-dot((x-y)*inv_cov_diag,x-y)/2);
    prior(i)=exp(-dot((all_params(i,:)+6),(all_params(i,:)+6))/2)/exp(-dot((all_params(i,:)-param_orig),(all_params(i,:)-param_orig))/(2/9));
end


u_real=param_orig;
prior_std=[1 1 1 1];
prior_mean=[-6 -6 -6 -6];
MH_MULTIPLICITY=(prior.*likelihood)';
MH_SAMPLES=all_params;

