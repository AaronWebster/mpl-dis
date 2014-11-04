addpath('~/mpl-dis/includes')

mycolor = brewermap(5,'Set1');

figure(1)
clf;
subplot(411)
tmp = load('data/QCM00450-freq.txt');
plot(tmp(:,1)-tmp(1,1),tmp(:,2),'Color',mycolor(2,:));
ylim([-1 2])
ylabel('$\Delta\,f$ [Hz]');
legend('$\Delta\,f$');

subplot(412)
tmp = load('data/QCM00450-res.txt');
plot(tmp(:,1)-tmp(1,1),tmp(:,2),'Color',mycolor(1,:));
ylim([-0.5 0.5])
ylabel('$\Delta\Gamma$ [Hz]');
legend('$\Delta\Gamma$');

subplot(413)
tmp = load('data/QCM00450-temp.txt');
plot(tmp(:,1)-tmp(1,1),tmp(:,2),'Color',mycolor(3,:));
ylabel('$T$ [C]')
legend('$T$');


subplot(414)
tmp = load('data/QCM00450-ang.txt');
plot(tmp(:,1)-tmp(1,1),tmp(:,2),'Color',mycolor(4,:));
legend('g-force');
ylabel('g-force');
xlabel('time [s]');

ang = load('data/QCM00450-ang.txt');
temp =  load('data/QCM00450-temp.txt');

figure(2)
plot(ang(:,2),temp(:,2))

if false
filename = sprintf('showtempwater.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', false, ...
	'height', '2.5cm', 'width','12cm');
end
