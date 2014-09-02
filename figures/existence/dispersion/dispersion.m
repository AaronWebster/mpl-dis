clear all;
close all;
addpath('~/mpl-dis/includes')
metal = 'Ag';
model = 'LD';
c = get_constant('c','SI');
e = get_constant('e','SI');
hbar = get_constant('h','SI')/(2*pi);
omega = 2*pi*c./linspace(280e-9,2000e-9,1000);
e1 = 2.25;
% no damping
[e2,~] = LD(2*pi*c./omega,metal,model);
betad = (omega./c).*(sqrt(e1*e2./(e1+e2)));
% damping
e2 = LD(2*pi*c./omega,metal,model);
betan = (omega./c).*(sqrt(e1*e2./(e1+e2)));

% wp = 9.01*e/hbar;
% 
% %wp = 9.01*e/hbar;
% figure(1)
% clf;
% hold on;
% plot(real(betad),omega,imag(betad),omega,omega./c,omega)
% %line([0,6e7],[wp/sqrt(1+e2),wp/sqrt(1+e2)])
% axis([0 5e7 0e15 7e15])
% hold off;

figure(1)
clf;

hold on;
mycolor = brewermap(5,'Set1');
plot(real(betan),omega,'Color',mycolor(1,:))
plot(omega./c.*sqrt(e1),omega,'Color',mycolor(2,:))
plot(omega./c.*sqrt(e1)./sin(deg2rad(45)),omega,'Color',mycolor(3,:))
[peaks,locs] = findpeaks(real(betan))
line([0 5.5e7],[omega(locs(1)) omega(locs(1))],'LineStyle','--','Color',[0.75 0.75 0.75])
[peaks,locs] = findpeaks(-real(betan))
line([0 5.5e7],[omega(locs(1)) omega(locs(1))],'LineStyle','--','Color',[0.75 0.75 0.75])
axis([0 5.5e7 1e15 7e15])
text(3.499999999999997e7,6.556814289209689e15,'$ck/\sqrt{\epsilon_1}$')
text(4.78514056224899e7,6.327306092488375e15,'$ck\sin\theta/\sqrt{\epsilon_1}$')
xlabel('$k_x$');
ylabel('$\omega$');
legend('SPP/dielectric','photon/vacuum','photon/dielectric','Location','SouthEast');
hold off;

%plot(real(beta)./wp,omega./wp,imag(beta)./wp,omega./wp)


%axis([0 8e7 0e15 10e15])
%axis([0 2 0.3 1.1])

if true
filename = sprintf('/tmp/test.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', true, ...
        'height', '9cm', 'width','8cm');
end
out = [real(betan)' omega'];
save('-ascii','/tmp/sppdielectric.dat','out')
out = [(omega./c.*sqrt(e1))' omega'];
save('-ascii','/tmp/photondielectric.dat','out')
out = [(omega./c.*sqrt(e1)./sin(deg2rad(45)))', omega'];
save('-ascii','/tmp/photondielectrictilted.dat','out')