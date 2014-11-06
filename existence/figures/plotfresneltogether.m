clear all;
close all;
addpath('~/mpl-dis/includes')

load('fresnelsppA')
thetaA = theta;
lambdaA = lambda;
rpA = rp;

load('fresnelsppB')
thetaB = theta;
lambdaB = lambda;
rpB = rp;

figure(1)
clf;
colormap(brewermap([],'YlOrRd'));
subplot(121)
imagesc(thetaA,lambdaA,abs(flipud(rpA)).^2)
set(gca,'YDir','normal')
line([61.61 61.61],[min(lambdaA) max(lambdaA)],'LineStyle','--','Color',[0.4 0.4 0.4])
xlabel('$\theta$ [degrees]')
ylabel('$\lambda$ [m]')
subplot(122)
imagesc(thetaB,lambdaB,abs(flipud(rpB)).^2)
set(gca,'YDir','normal')
line([61.61 61.61],[min(lambdaA) max(lambdaA)],'LineStyle','--','Color',[0.4 0.4 0.4])
xlabel('$\theta$ [degrees]')
ylabel('$\lambda$ [m]')
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', '$|r_p|^2$');

if true
%% save to file
filename = sprintf('fresneltogether.tex');
matlab2tikz(filename, 'showInfo', false, ...
         'parseStrings',false,'standalone', false, ...
         'height', '5.5cm', 'width','5.5cm');
end