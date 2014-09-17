function RP = fresnel_ssp( theta )
%% calculates the fresnel reflection and transmission for the symmetric (long range) configuration
addpath('~/mpl-dis/code/mrf_SPP_speckle')
addpath('~/mpl-dis/includes')

rp = zeros(1,length(theta));
tp = zeros(1,length(theta));

lambda = 660e-9;
k0 = 2*pi/lambda;

eps_met = LD(lambda,'Au','LD');
n1 = nBK7(lambda);
n2 = nCYT(lambda);
n3 = sqrt(eps_met);
n4 = nH20(lambda);
d2 = 1164e-9;
d3 = 16.97e-9;
nJ = [n1,n2,n3,n4];
dJ = [0,d2,d3,0];
kx0 = k0*n1*sin(deg2rad(theta));

for i=1:length(kx0)
    [Mp, Ms] = transfer_matrix_multi(k0,kx0(i),nJ,dJ);
    [rp(i),~,tp(i)] = trans_mat_2_fresnel(Mp,Ms);
end

RP = abs(rp).^2;
%TP = abs(tp).^2;

end