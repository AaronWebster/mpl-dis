% test of comsol goodness using the impediance gk thing
%close all;
clear all;
fs = 5e6;
wq = 2*pi*fs;
rhoq = 2648;
muq = 2.947e10;
rhol = 1060;
Nl = 1/(10e-6);
Lu = 0.040;
Zq = 8.8e6;
n = 1;

a = dlmread('comsol_output-visco2.csv',',',5,0);

% simulation data
x = a(:,1);
sigma = a(:,2);
udot = a(:,3);
y = 1.0i/(pi*Zq).*sigma./udot.*fs;

% theory
v = linspace(min(x),max(x),100);
t = 1.0/(pi*Zq)*(-1+i)/sqrt(2)*sqrt(1000*wq*(0.001-1.0i.*v))*fs*n;

figure(1);
plot(x,real(y),x,imag(y),v,real(t),v,imag(t))

% output theory then experiment
out = [ x real(y) imag(y) ];
save('-ascii','gksimulation2.dat','out');

out = [ v' real(t)' imag(t)' ];
save('-ascii','gktheory2.dat','out');

