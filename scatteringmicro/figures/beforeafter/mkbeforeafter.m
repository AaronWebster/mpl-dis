% transition time about 100ms
close all;
clear all;

addpath('~/mpl-dis/includes')
load('../basisdescribe.mat');
la = 27136;
lb = 27481;
ntmp = ntmp./1000;
time_a = time_a(la:lb)./1000;
time_a = time_a - ntmp(31);
spkcorr = spkcorr(la:lb);
%text(ntmp(:,1), ntmp(:,2), labels, 'VerticalAlignment','bottom','HorizontalAlignment','right')
line([ntmp(31) ntmp(31)],get(gca,'YLim'),'LineStyle','--');
figure(1)
subplot(2,2,[1:2])
mycolor = brewermap(5,'Set1');
plot(time_a,spkcorr,'Color',mycolor(2,:))
xlabel('time [s]')
ylabel('$C_I$');
ntmp = ntmp - ntmp(31);
line([ntmp(31) ntmp(31)],get(gca,'YLim'),'Color',mycolor(1,:))
set(gca,'Xlim',[-1,1])
legend('$C_I$','event');

subplot(2,2,3);
load('fbefore.mat');
imagesc(outframe);

subplot(2,2,4);
load('fafter.mat');
imagesc(outframe);


legend('$C_I$','event');
filename = sprintf('/tmp/test.tex');
matlab2tikz(filename, 'showInfo', false, ...
'parseStrings',false,'standalone', true, ...
'height', '3.5cm', 'width','9cm');



