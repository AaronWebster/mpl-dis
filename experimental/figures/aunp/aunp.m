% plots aunp spectrums
close all;
clear all;

addpath('~/mpl-dis/includes')
a25 = load('nanopartz25k.csv');
a50 = load('nanopartz50k.csv');
a57 = load('original.dat');
a75 = load('nanopartz75k.csv');
a100 = load('nanopartz100k.csv');

l = linspace(460,760,100);

figure(1)
hold on;
mycolor = brewermap(5,'Set1');

a = a25;
a(:,2) = (a(:,2)-min(a(:,2)))./range(a(:,2));
a(:,2) = smooth(a(:,1),a(:,2),0.3,'loess');
F = fit(a(:,1),a(:,2),'smoothingspline')
[X,IX] = max(F(l));
peak = l(IX);
d = -(522-peak);
F = fit(a(:,1)-d,a(:,2),'smoothingspline')
[X,IX] = max(F(l));
plot(l,F(l)+(1-X),'Color',mycolor(1,:),'LineStyle','-')

a = a50;
a(:,2) = (a(:,2)-min(a(:,2)))./range(a(:,2));
a(:,2) = smooth(a(:,1),a(:,2),0.3,'loess');
F = fit(a(:,1),a(:,2),'smoothingspline')
[X,IX] = max(F(l));
peak = l(IX);
d = -(532-peak);
F = fit(a(:,1)-d,a(:,2),'smoothingspline')
plot(l,F(l)+(1-X),'Color',mycolor(2,:),'LineStyle','--')

a = a75;
a(:,2) = (a(:,2)-min(a(:,2)))./range(a(:,2));
a(:,2) = smooth(a(:,1),a(:,2),0.3,'loess');
F = fit(a(:,1),a(:,2),'smoothingspline')
[X,IX] = max(F(l));
peak = l(IX);
d = -(545-peak);
F = fit(a(:,1)-d,a(:,2),'smoothingspline')
plot(l,F(l)+(1-X),'Color',mycolor(3,:),'LineStyle',':')

a = a100;
a(:,2) = (a(:,2)-min(a(:,2)))./range(a(:,2));
a(:,2) = smooth(a(:,1),a(:,2),0.3,'loess');
F = fit(a(:,1),a(:,2),'smoothingspline')
[X,IX] = max(F(l));
peak = l(IX);
d = -(566-peak);
F = fit(a(:,1)-d,a(:,2),'smoothingspline')
plot(l,F(l)+(1-X),'Color',mycolor(4,:),'LineStyle','-.')


xlabel('wavelength [nm]')
ylabel('normalized absorbance [a.u.]')
legend('\SI{25}{\nano\meter}', '\SI{50}{\nano\meter}', '\SI{75}{\nano\meter}', '\SI{100}{\nano\meter}')

filename = sprintf('../aunpspectrum.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', false, ...
        'height', '5cm', 'width','10cm');
