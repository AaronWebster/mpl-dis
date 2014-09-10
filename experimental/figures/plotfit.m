addpath('~/mpl-dis/includes')
a = load('fitfresnel.dat');
figure(1)
clf;
hold on;
mycolor = brewermap(5,'Set1');
plot(a(:,1),a(:,2),'Color',mycolor(1,:))
plot(a(:,1),a(:,3),'o','Color',mycolor(2,:))
xlabel('wavelength [m]')
ylabel('$|r|^2$')
legend('fit','data')
hold off;

filename = sprintf('/tmp/fresnelfit.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', true, ...
        'height', '9cm', 'width','18cm');
