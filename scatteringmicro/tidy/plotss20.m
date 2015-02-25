addpath('~/mpl-dis/includes')
load('pearsons_20_singlescattering.mat')

figure(1)
clf
hold on;
mycolor = brewermap(5,'Set1');
plot(x,out,'o','Color',mycolor(2,:));
plot(x,20./x,'Color',mycolor(1,:));
xlabel('number of scatterers');
ylabel('$C_I$');
legend('simulation','theory');

filename = sprintf('../figures/pearsonssinglescatt20.tex');
matlab2tikz(filename, 'showInfo', false, ...
'parseStrings',false,'standalone', false, ...
'height', '5cm', 'width','9cm');

