function TP = fresnel_ssp_tp( theta, dn )
%% calculates the fresnel reflection and transmission for the symmetric (long range) configuration
addpath('~/mpl-dis/code/mrf_SPP_speckle')
addpath('~/mpl-dis/includes')

tp1 = zeros(1,length(theta));
tp2 = zeros(1,length(theta));

lambda = 660e-9;
k0 = 2*pi/lambda;

eps_met = LD(lambda,'Au','LD');
n1 = nBK7(lambda);
n2 = nCYT(lambda);
n3 = sqrt(eps_met);
n4 = nH20(lambda);
d2 = 1164e-9;
d3 = 16.97e-9;
nJ = [n1,n2,n3,n4+dn];
dJ = [0,d2,d3,0];
kx0 = k0*n1*sin(deg2rad(theta));

for i=1:length(kx0)
    [Mp, Ms] = transfer_matrix_multi(k0,kx0(i),nJ,dJ);
    [~,~,tp1(i)] = trans_mat_2_fresnel(Mp,Ms);
end

% reverse
nJ = nJ(end:-1:1);
for i=1:length(kx0)
    [Mp, Ms] = transfer_matrix_multi(k0,kx0(i),nJ,dJ);
    [~,~,tp2(i)] = trans_mat_2_fresnel(Mp,Ms);
end

TP = abs(tp1).^2.*abs(tp2).^2;
%if length(TP) > 1
%    TP = (TP-min(TP))./range(TP);
%end
%TP = abs(tp).^2;

end