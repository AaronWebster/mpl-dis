function TP = fresnel_jiapeng_tp( theta, dn )
%% calculates the fresnel reflection and transmission
addpath('~/mpl-dis/code/mrf_SPP_speckle')
addpath('~/mpl-dis/includes')

tp1 = zeros(1,length(theta));
tp2 = zeros(1,length(theta));

lambda = 660e-9;
k0 = 2*pi/lambda;
n1 = nLAH79(lambda);
n2 = sqrt(LD(lambda,'Au','LD'));
n3 = nH20(lambda);
d2 = 45e-9;
nJ = [n1,n2,n3+dn];
dJ = [0,d2,0];
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