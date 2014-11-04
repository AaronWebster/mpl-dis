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

subplot(122)
ang = load('data/QCM00431b-ang.txt');
temp =  load('data/QCM00431b-temp.txt');
hold on;
plot(ang(:,2),temp(:,2),'Color',mycolor(1,:))
xlabel('g-force [g]')
ylabel('$T$ [C]')


if true
filename = sprintf('/tmp/test.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', true, ...
	'height', '5cm', 'width','5cm');
end
