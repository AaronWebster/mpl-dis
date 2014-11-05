addpath('~/mpl-dis/includes')

mycolor = brewermap(5,'Set1');

figure(1)
clf;
subplot(411)
tmp = load('data/QCM00431b-freq.txt');
plot(tmp(:,1)-tmp(1,1),tmp(:,2),'Color',mycolor(2,:));
ylim([-1 4])
ylabel('$\Delta\,f$ [Hz]');
legend('$\Delta\,f$');

subplot(412)
tmp = load('data/QCM00431b-res.txt');
plot(tmp(:,1)-tmp(1,1),tmp(:,2),'Color',mycolor(1,:));
ylim([-0.05 0.2])
ylabel('$\Delta\Gamma$ [Hz]');
legend('$\Delta\Gamma$');

subplot(413)
tmp = load('data/QCM00431b-temp.txt');
plot(tmp(:,1)-tmp(1,1),tmp(:,2),'Color',mycolor(3,:));
ylabel('$T$ [C]')
legend('$T$');


subplot(414)
tmp = load('data/QCM00431b-ang.txt');
plot(tmp(:,1)-tmp(1,1),tmp(:,2),'Color',mycolor(4,:));
legend('g-force');
ylabel('g-force');
xlabel('time [s]');

if true
filename = sprintf('showtempair.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', false, ...
	'height', '2.5cm', 'width','12cm');
end
