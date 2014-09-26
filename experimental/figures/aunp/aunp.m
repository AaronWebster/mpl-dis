% plots aunp spectrums

addpath('~/mpl-dis/includes')
a = load('original.dat');

xa = a(:,1);
ya = a(:,2);

idxa = find(xa>400,1);
idxb = find(xa>800,1);
xa = xa(idxa:idxb);
ya = ya(idxa:idxb);

figure(1)
mycolor = brewermap(5,'Set1');
plot(xa,ya,'Color',mycolor(2,:))
xlabel('wavelength [nm]')
ylabel('absorbance [a.u.]')
legend('57nm AuNPs')

filename = sprintf('../aunpspectrum.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', false, ...
        'height', '5cm', 'width','9cm');
