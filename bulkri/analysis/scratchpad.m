addpath('~/mpl-dis/code/mrf_SPP_speckle')
addpath('~/mpl-dis/includes')
addpath('~/mpl-dis/bulkri/figures')


lambda = 660e-9;
k0 = 2*pi/lambda;
c = 299792458;
eps_met = LD(lambda,'Au','LD');
(4*sqrt(3)/9)*(real(eps_met)^2/(imag(eps_met)*nBK7(lambda)^3))

%4*sqrt(3)*real(eps_met)^2/(9*imag(eps_met))

sensorthing = (real(eps_met)/(real(eps_met)+nH20(lambda)^2))^(3/2)

%eps_met = LD(lambda,'Au','D');
%4*sqrt(3)*real(eps_met)^2/(9*imag(eps_met)*nH20(lambda)^3)

% lambda = linspace(600e-9,900e-9,1000);
% eps_met = LD(lambda,'Au','LD');
% sens = 4.*sqrt(3).*real(eps_met).^2./(9.*imag(eps_met).*nH20(lambda).^3);
% semilogy(lambda,sens);

dn=0.001;
ta = 40;
tb = 85; 
theta = linspace(ta,tb,2000);
max(abs(fresnel_asp_rp(theta,0)-fresnel_asp_rp(theta,dn)))/dn

a = load('drdn-homola-sp.csv');
x = a(:,1).*1e-9;
y = a(:,2);
F = fit(x,y,'smoothingspline');
F(660e-9)


1/k0*real(k0*sqrt(nBK7(lambda)*eps_met/(nBK7(lambda)+eps_met)))

%*(real(eps_met)/(real(eps_met)+nH20(lambda)^2))^(3/2)