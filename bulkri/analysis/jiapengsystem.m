addpath('~/mpl-dis/code/mrf_SPP_speckle')
addpath('~/mpl-dis/includes')
addpath('~/mpl-dis/bulkri/figures')

%% quick look
lambda = 660e-9;
k0 = 2*pi/lambda;
c = 299792458;

theta = linspace(30,65,1000);

rp = fresnel_jiapeng_rp(theta,0);
tp = fresnel_jiapeng_tp(theta,0);
tp = (tp-min(tp))./range(tp);
rp = (rp-min(rp))./range(rp);

% angular width in notch
ta = find(rp<0.5,1);
tb = find(rp(end:-1:1)<0.5,1);
aspnotch = theta(length(theta)-tb) - theta(ta)

% angular width in cone
ta = find(tp>0.5,1);
tb = find(tp(end:-1:1)>0.5,1);
aspcone = theta(length(theta)-tb) - theta(ta)


plot(theta,rp,theta,tp)


%% stop looking!
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