% spot size plot
% data generated on lab in /mnt/disk0/lookimg/calcSpeckleSize.m

clear all;
close all;
addpath('~/mpl-dis/includes')

load('spotsizenew.mat');

mycolor = brewermap(5,'Set1');
plot(x,y,'Color',mycolor(2,:));
xlabel('reference spot size [um]');
ylabel('speckle size [deg]');
axis([min(x) max(x) 0 0.8 ])

filename = sprintf('../spotsizefig.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', true, ...
        'height', '3.5cm', 'width','9cm');
