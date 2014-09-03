function [nh20,kh20] = nH20(lambda) 

if lambda<0.2e-9
	lambda=0.2e-9;
end

data = load('Water_Hale.txt');
lam = 1e-6*data(:,1);
n   = data(:,2);
k   = data(:,3);

nh20 = interp1(lam,n,lambda);
kh20 = interp1(lam,k,lambda);
