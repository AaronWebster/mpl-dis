clear all;
close all;
addpath('~/mpl-dis/includes')

a = load('cytopthick.dat');
x = a(:,1);
y = a(:,2);
e = a(:,3);

figure(1)
mycolor = brewermap(5,'Set1');
errorbar(x,y,e,'Color',mycolor(2,:))
xlabel('spin speed [RPM]')
ylabel('layer thickness [m]')
legend('cytop layer thickness')

filename = sprintf('cytopthicknessfig.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '6cm', 'width','9cm');
