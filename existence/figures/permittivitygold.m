mycolor = brewermap(4,'Paired');
lambda = linspace(250e-9,1000e-9,500);
epsilonLD = LD(lambda,'Au','LD');
epsilonD = LD(lambda,'Au','D');

figure(1)
clf;
hold on;
plot(lambda,real(epsilonLD),'Color',mycolor(2,:));
plot(lambda,imag(epsilonLD),'Color',mycolor(4,:));
plot(lambda,real(epsilonD),'Color',mycolor(1,:));
plot(lambda,imag(epsilonD),'Color',mycolor(3,:));
xlabel('wavelength [m]')
ylabel('$\epsilon$ [F/m]')
legend(...
'$\epsilon^\prime_\mathrm{LD}$',...
'$\epsilon^{\prime\prime}_\mathrm{LD}$',...
'$\epsilon^\prime_\mathrm{D}$',...
'$\epsilon^{\prime\prime}_\mathrm{D}$',...
'Location','SouthWest'...
);
hold off;

%filename = sprintf('permittivityau.tex');
%matlab2tikz(filename, 'showInfo', false, ...
%        'parseStrings',false,'standalone', false, ...
%        'height', '4cm', 'width','12cm');
