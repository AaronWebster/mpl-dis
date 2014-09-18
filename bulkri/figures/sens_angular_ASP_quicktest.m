% test angular sensitivity

%% initialize variables
clear all;
close all;
addpath('~/mpl-dis/code/mrf_SPP_speckle')

% angle range to look at
ta = 55;
tb = 85;
theta = linspace(ta,tb,10000);

% fresnel r and t for both polarizations
rp1 = zeros(1,length(theta));
rp2 = zeros(1,length(theta));
tp1 = zeros(1,length(theta));
tp2 = zeros(1,length(theta));

% wavelength, thicknesses, and refractive indicies
lambda = 660e-9;
k0 = 2*pi/lambda;
n1 = nBK7(lambda);
n2 = sqrt(LD(lambda,'Au','LD'));
n3 = nH20(lambda);
d2 = 45e-9;
nJ = [n1,n2,n3];
dJ = [0,d2,0];
kx0 = k0*n1*sin(deg2rad(theta));

out = zeros(1,10);
j = 1;
nr = linspace(1.30,1.35,10);
for j = 1:10
    nJ = [n1,n2,n3];
    %% calculate angular spectrum
    parfor i=1:length(kx0)
        [Mp, Ms] = transfer_matrix_multi(k0,kx0(i),nJ,dJ);
        [rp1(i),~,tp1(i)] = trans_mat_2_fresnel(Mp,Ms);
    end
    RP1 = abs(rp1).^2;
    FR1 = fit(theta',RP1','smoothingspline');
    out(j) = fminbnd(FR1,ta,tb);
end

%figure(2)
%plot(abs((1+rp1.*rp2.*exp(2.0i.*k0.*d2)).^-4)).^2;