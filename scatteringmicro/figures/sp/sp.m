clear all;
close all;
addpath('~/mpl-dis/includes')



% load data
load('smooth.mat');
load('rough.mat');
load('smooth1.mat');

mycolor = brewermap(5,'Set1');

x = 0:5:30;
x_c = 0:0.1:30;

theo =1.05* tan(pi*x_c/180).^2./(1+tan(pi*x_c/180).^2);
fig = figure;
hold on;
eb_1=errorbar(x,smooth.dmean,smooth.dstd,'Color',mycolor(1,:));
eb_2 = errorbar(x,rough.dmean,rough.dstd,'Color',mycolor(2,:));

plot(smooth1.a(:,1),smooth1.a(:,2)./smooth1.b(:,2),'Color',mycolor(4,:))
plot(x_c,theo,'Color',mycolor(3,:))

xlabel('angle [deg]');
ylabel('$I_p/I_s$ [a.u.]');
legend('measured smooth','measured rough','theoretically perfect smooth','Location','NorthWest');


if true
    filename = sprintf('../spfig.tex');
    matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '9cm', 'width','9cm');
end
