addpath('~/mpl-dis/includes')
mycolor = brewermap(8,'Paired');
lambda = linspace(250e-9,1300e-9,500);
epsilonLD = LD(lambda,'Au','LD');
epsilonD = LD(lambda,'Au','D');

% load experimental data

ev2nm = @(x) (1239.84187)./x;

doldmeker1 = load('DoldMeke_r1');
doldmeker1(:,1) = ev2nm(doldmeker1(:,1));
doldmeker2 = load('DoldMeke_r1');
doldmeker2(:,1) = ev2nm(doldmeker2(:,1));

theker1 = load('Theye_r1');
theker1(:,1) = ev2nm(theker1(:,1));
theker2 = load('Theye_r2');
theker2(:,1) = ev2nm(theker2(:,1));

figure(1)
clf;
hold on;
plot(lambda,real(epsilonLD),'Color',mycolor(2,:));
plot(lambda,imag(epsilonLD),'Color',mycolor(4,:));
plot(lambda,real(epsilonD),'Color',mycolor(1,:));
plot(lambda,imag(epsilonD),'Color',mycolor(3,:));
plot(theker1(:,1).*1e-9,-theker1(:,2),'x','Color',mycolor(5,:));
plot(theker2(:,1).*1e-9,theker2(:,2),'x','Color',mycolor(7,:));
xlabel('wavelength [m]')
ylabel('$\epsilon$ [F/m]')
legend(...
'$\epsilon^\prime_\mathrm{LD}$',...
'$\epsilon^{\prime\prime}_\mathrm{LD}$',...
'$\epsilon^\prime_\mathrm{D}$',...
'$\epsilon^{\prime\prime}_\mathrm{D}$',...
'$\epsilon^\prime_\mathrm{Thèye}$',...
'$\epsilon^{\prime\prime}_\mathrm{Thèye}$',...
'Location','SouthWest'...
);
hold off;

if false
filename = sprintf('permittivityau.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '4cm', 'width','12cm');
end
