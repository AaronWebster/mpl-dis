clear all;
close all;
addpath('~/mpl-dis/includes')
metal = 'Ag';
model = 'LD';
c = get_constant('c','SI');
e = get_constant('e','SI');
hbar = get_constant('h','SI')/(2*pi);
N=2000;

%omega = linspace(2*pi*c./2000e-9,2*pi*c./200e-9,500);
omega = 2*pi*c./linspace(280e-9,2000e-9,N);
%omega = omega(end:-1:1);
kx = linspace(0,10e7,N);
e1 = 1.331.^2;
e3 = 1.332.^2;
a = 15e-9/2;

[KX, OMEGA] = meshgrid(kx,omega);

k0 = (OMEGA./c);
e2 = LD(2*pi*c./OMEGA,metal,model);
k1 = sqrt(e1.*k0.^2-KX.^2);
k2 = sqrt(e2.*k0.^2-KX.^2);
k3 = sqrt(e3.*k0.^2-KX.^2);
%out = KX-k0.*sqrt(e1.*e2./(e1+e2));
%out = abs(real(k2./e2-k1./e1));
%out = abs(real(tanh(k1.*a)+k2.*e1./(k1.*e2)));
out = (exp(-4.*k1./e1)-((k1./e1+k2./e2)./(k1./e1-k2./e2)).*((k1./e1+k3./e3)./(k1./e1-k3./e3)));
figure(1);
%out(out>100)=0;
imagesc(kx,omega,log((abs(real(out)))));
set(gca,'YDir','normal')
hold on;
plot(kx,c.*kx./sqrt(e1))
hold off;
xlabel('$k_x$');
ylabel('$\omega$');