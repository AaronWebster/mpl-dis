addpath('~/mpl-dis/includes')
mycolor = brewermap(5,'Set1');

% figure(1)
% clf;
% subplot(411)
% ang = load('data/QCM00431b-ang.txt');
% temp =  load('data/QCM00431b-temp.txt');
% plot(temp(:,1),temp(:,2),'Color',mycolor(2,:))
% subplot(412)
% plot(ang(:,1),ang(:,2),'Color',mycolor(2,:))
% subplot(413)
% ang = load('data/QCM00450-ang.txt');
% temp =  load('data/QCM00450-temp.txt');
% plot(temp(:,1),temp(:,2),'Color',mycolor(2,:))
% subplot(414)
% plot(ang(:,1),ang(:,2),'Color',mycolor(2,:))

figure(1)
clf;
subplot(121)
ang = load('data/QCM00450-ang.txt');
temp =  load('data/QCM00450-temp.txt');
plot(ang(:,2),temp(:,2),'Color',mycolor(2,:))
xlabel('g-force [g]')
ylabel('$T$ [C]')
legend('Air','Location','SouthEast')

subplot(122)
ang = load('data/QCM00431b-ang.txt');
temp =  load('data/QCM00431b-temp.txt');
plot(ang(:,2),temp(:,2),'Color',mycolor(1,:))
xlabel('g-force [g]')
ylabel('$T$ [C]')
legend('Water','Location','SouthEast')

if true
filename = sprintf('showtempairwater.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', false, ...
	'height', '6cm', 'width','6cm');
end
