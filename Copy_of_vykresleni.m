
data1=load('~/Downloads/onefrac.mat');
data2=load('~/one_frac.mat');
all_Q=[data1.all_Q];
all_params=[data1.all_params];

sigma_num=1e-11;
sigma_obs=1e-13;
sigma_both=1e-11^2/4+sigma_obs^2;
inv_cov_diag=1/sigma_both;

mask=[2 3 4 5 7 8 9 10 12 13 14 15 17 18 19 20];
param_orig=[-7];
rng(2)
x=data2.Q_ref;

for i=1:400
    y=all_Q(i,:);
    likelihood(i)=exp(-dot((x-y)*inv_cov_diag,x-y)/2);
    prior(i)=exp(-dot((all_params(i)+6),(all_params(i)+6))/2);
end


% u_real=param_orig;
% prior_std=[1 1 1 1];
% prior_mean=[-6 -6 -6 -6];
% MH_MULTIPLICITY=(prior.*likelihood)';
% MH_SAMPLES=all_params;

