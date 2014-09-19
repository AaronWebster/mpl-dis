addpath('~/mpl-dis/includes')

%% load data, get fits
r123 = load('1000_r123.dat');
Fa = fit(r123(:,1),r123(:,2),'smoothingspline');
gauss = load('1000_gauss.dat');
Fb = fit(gauss(:,1),gauss(:,2),'smoothingspline');
r123m12f = load('1000_r123m12.dat');
Fc = fit(r123m12f(:,1),r123m12f(:,2),'smoothingspline');

%% plot data
x = linspace(530,700,500);
mycolor = brewermap(5,'Set1');
figure(1)
clf;
hold on;
plot(x,Fa(x),'Color',mycolor(2,:))
plot(x,Fb(x),'Color',mycolor(3,:))
plot(x,Fc(x),'Color',mycolor(1,:))
xlabel('detector scale [a.u.]')
ylabel('intensity [a.u.]')
legend('$r_{123}$','$r_{123}-r_{12}$','g(x)')

filename = sprintf('r123m12.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', false, ...
        'height', '6cm', 'width','10cm');

