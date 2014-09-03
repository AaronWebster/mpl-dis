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

figure(1)
clf;
xmin = 0;
xmax = 5.5e7;
ymin = 1e15;
ymax = 7e15;
hold on;
% filled box
[~,locs1] = findpeaks(real(betan));
[~,locs2] = findpeaks(-real(betan));
mycolor = brewermap(5,'Blues');
fill([-1e7 6e7 6e7 -1e7],[omega(locs1(1)) omega(locs1(1)) omega(locs2(1)) omega(locs2(1)) ],mycolor(1,:))
line([0 xmax],[omega(locs2(1)) omega(locs2(1))],'LineStyle','--','Color',[0.75 0.75 0.75])
line([0 xmax],[omega(locs1(1)) omega(locs1(1))],'LineStyle','--','Color',[0.75 0.75 0.75])
% plots
legend off;
mycolor = brewermap(5,'Set1');
p1 = plot(real(betan),omega,'Color',mycolor(1,:));
p2 = plot(omega./c.*sqrt(e1),omega,'Color',mycolor(2,:));
p3 = plot(omega./c.*sqrt(e1)./sin(deg2rad(45)),omega,'Color',mycolor(3,:));
axis([xmin xmax ymin ymax]);

% gtexts
text(3.499999999999997e7,6.556814289209689e15,'$ck/\sqrt{\epsilon_1}$')
text(4.2e7,5.75e15,'$ck\sin\theta/\sqrt{\epsilon_1}$')
text(0.25e7,omega(locs1(1))+abs(omega(locs1(1))-omega(locs2(1)))/2,'quasi-bound');
text(0.25e7,omega(locs1(1))-abs(omega(locs1(1))-omega(locs2(1)))/2,'bound');
text(0.25e7,omega(locs2(1))+abs(omega(locs1(1))-omega(locs2(1)))/2,'radiative');
xlabel('$k_x$');
ylabel('$\omega$');
legend([p1 p2 p3], {'SPP/dielectric','photon/vacuum','photon/dielectric'},'Location','SouthEast');
hold off;


if false
filename = sprintf('dispersionfig.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '9cm', 'width','9cm');
end
