clear all;
close all;
addpath('~/mpl-dis/includes')

% load data
load('smooth.mat');
load('rough.mat');
load('smooth1.mat');

mycolor = brewermap(5,'Set1');
eps_met = LD(633e-9,'Ag','LD');

x = 0:5:30;
x_c = 0:0.1:30;

figure(1);
clf;

hold on;
eb_2 = errorbar(x,rough.dmean,rough.dstd,'Color',mycolor(2,:));
eb_1 = errorbar(x,smooth.dmean,smooth.dstd,'Color',mycolor(1,:));

%plot(smooth1.a(:,1),smooth1.a(:,2)./smooth1.b(:,2),'Color',mycolor(4,:))

theo =tan(deg2rad(x_c)).^2./(1+tan(deg2rad(x_c)).^2./abs(eps_met));
plot(x_c,theo,'Color',mycolor(3,:))

xlabel('angle [deg]');
ylabel('$I_p/I_s$ [a.u.]');
legend('measured rough','measured smooth','theoretical perfect smoothness','Location','NorthWest');


if true
    filename = sprintf('../spfig.tex');
    matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '9cm', 'width','9cm');
end
