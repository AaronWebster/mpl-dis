addpath('~/mpl-dis/includes')
a = load('fitfresnel.dat');
figure(1)
clf;
hold on;
mycolor = brewermap(5,'Set1');
plot(a(:,1),a(:,2),'Color',mycolor(1,:))
plot(a(:,1),a(:,3),'o','Color',mycolor(2,:))
xlabel('wavelength [m]')
ylabel('$R$')
legend('fit','data')
hold off;

filename = sprintf('fresnelfit.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '4cm', 'width','12cm');
