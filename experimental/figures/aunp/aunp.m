% plots aunp spectrums
close all;
clear all;

addpath('~/mpl-dis/includes')
a25 = load('nanopartz25k.csv');
a50 = load('nanopartz50k.csv');
a57 = load('original.dat');
a75 = load('nanopartz75k.csv');
a100 = load('nanopartz100k.csv');

l = linspace(450,800,1000);

figure(1)
hold on;
mycolor = brewermap(5,'Set1');

a = a25;
a(:,2) = (a(:,2)-min(a(:,2)))./range(a(:,2));
F = fit(a(:,1),a(:,2),'linearinterp')
[X,IX] = max(F(l));
peak = l(IX);
d = -(522-peak);
F = fit(a(:,1)-d,a(:,2),'linearinterp')
plot(l,F(l),'Color',mycolor(1,:))

a = a50;
a(:,2) = (a(:,2)-min(a(:,2)))./range(a(:,2));
F = fit(a(:,1),a(:,2),'linearinterp')
[X,IX] = max(F(l));
peak = l(IX);
d = -(532-peak);
F = fit(a(:,1)-d,a(:,2),'linearinterp')
plot(l,F(l),'Color',mycolor(2,:))

%a = a57;
%a(:,2) = (a(:,2)-min(a(:,2)))./range(a(:,2));
%F = fit(a(:,1),a(:,2),'linearinterp')
%[X,IX] = max(F(l));
%peak = l(IX);
%d = -(532-peak);
%F = fit(a(:,1)-d,a(:,2),'linearinterp')
%plot(l,F(l),'Color',mycolor(2,:))

a = a75;
a(:,2) = (a(:,2)-min(a(:,2)))./range(a(:,2));
F = fit(a(:,1),a(:,2),'linearinterp')
[X,IX] = max(F(l));
peak = l(IX);
d = -(545-peak);
F = fit(a(:,1)-d,a(:,2),'linearinterp')
plot(l,F(l),'Color',mycolor(3,:))

a = a100;
a(:,2) = (a(:,2)-min(a(:,2)))./range(a(:,2));
F = fit(a(:,1),a(:,2),'linearinterp')
[X,IX] = max(F(l));
peak = l(IX);
d = -(566-peak);
F = fit(a(:,1)-d,a(:,2),'linearinterp')
plot(l,F(l),'Color',mycolor(4,:))


xlabel('wavelength [nm]')
ylabel('absorbance [a.u.]')
legend('\SI{25}{\nano\meter}', '\SI{50}{\nano\meter}', '\SI{75}{\nano\meter}', '\SI{100}{\nano\meter}')

filename = sprintf('../aunpspectrum.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', false, ...
        'height', '5cm', 'width','9cm');
