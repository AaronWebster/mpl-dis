clear all;
close all;
addpath('~/mpl-dis/includes')
mycolor = brewermap(5,'Set1');

figure(1);
clf;
hold on;
xa = linspace(0,1,100);
xb = linspace(1,sqrt(2),20);
ya = 2.*xa.*(xa.^2-4.*xa+pi);
yb = 2.*xb.*(4.*sqrt(xb.^2-1)-(xb.^2+2-pi)-4.*atan(sqrt(xb.^2-1)));
x = [xa xb];
y = [ya yb];
plot(x,y,'Color',mycolor(2,:))

R = 1/2;
ya = 4.*xa./(pi.*R.^2).*acos(xa./(2.*R))-2.*xa.^2/(pi.*R.^3).*sqrt(1-xa.^2./(4.*R.^2));
plot(xa,ya,'Color',mycolor(1,:))

xlabel('$l$')
ylabel('$P(l)$')
legend('square','disk')

filename = sprintf('pdfpicking.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', false, ...
				'height', '5cm', 'width','9cm');