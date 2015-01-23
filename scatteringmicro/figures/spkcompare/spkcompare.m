clear all;
close all;
addpath('~/mpl-dis/includes')

a = imread('before_a.tif');
b = imread('before_b.tif');

va = load('Values-a.txt');
vb = load('Values-b.txt');

va = va(:,2);
va = (va-min(va))./range(va);
%va = va+abs(min(va));
vb = vb(:,2);
vb = (vb-min(vb))./range(vb);
%vb = vb+abs(min(vb));

figure(1)

subplot(311)
imagesc(a)
xlabel('detector scale [px]')
ylabel('detector scale [px]')
title('\textbf{speckle a}')

subplot(312)
imagesc(b)
xlabel('detector scale [px]')
ylabel('detector scale [px]')
title('\textbf{speckle b}')

subplot(313)
hold on;
mycolor = brewermap(5,'Set1');
plot(va,'Color',mycolor(2,:))
plot(vb,'Color',mycolor(1,:))
hold off;
xlabel('detector scale along cone [px]')
ylabel('intensity [a.u.]')
legend('speckle a','speckle b','Location','northwest')

filename = sprintf('spkcompare.tex');
matlab2tikz(filename, 'showInfo', false, ...
'parseStrings',false,'standalone', false, ...
'height', '3.5cm', 'width','12cm');

