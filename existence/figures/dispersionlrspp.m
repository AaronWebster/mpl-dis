clear all;
close all;
addpath('~/mpl-dis/includes')
metal = 'Ag';
model = 'LD';
c = get_constant('c','SI');
e = get_constant('e','SI');
hbar = get_constant('h','SI')/(2*pi);
N=2000;

%omega = linspace(2*pi*c./2000e-9,2*pi*c./200e-9,500);
omega = 2*pi*c./linspace(330e-9,1000e-9,N);
%omega = omega(end:-1:1);
kx = linspace(0,7e7,N);
e1 = 1.331.^2;
e3 = 1.332.^2;
a = 15e-9/2;

[KX, OMEGA] = meshgrid(kx,omega);

k0 = (OMEGA./c);
e2 = LD(2*pi*c./OMEGA,metal,model);
k1 = sqrt(e1.*k0.^2-KX.^2);
k2 = sqrt(e2.*k0.^2-KX.^2);
k3 = sqrt(e3.*k0.^2-KX.^2);
%out = KX-k0.*sqrt(e1.*e2./(e1+e2));
%out = abs(real(k2./e2-k1./e1));
%out = abs(real(tanh(k1.*a)+k2.*e1./(k1.*e2)));
out = (exp(-4.*k1./e1)-((k1./e1+k2./e2)./(k1./e1-k2./e2)).*((k1./e1+k3./e3)./(k1./e1-k3./e3)));
figure(1);
%out(out>100)=0;
imagesc(kx,omega,log((abs(real(out)))));
colormap(brewermap([],'RdBu'));
set(gca,'YDir','normal')
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', '$log\left(\Re\left(|\mathrm{rhs}-\mathrm{lhs}|\right)\right)$');
annotation(gcf,'textarrow',[0.429090909090909 0.398181818181818],...
    [0.761295081967216 0.815573770491805],'TextEdgeColor','none',...
        'String',{'SPP mode'});
%hold on;
%plot(kx,c.*kx./sqrt(e1))
hold off;
xlabel('$k_x$');
ylabel('$\omega$');

if true
%filename = sprintf('lrsppdispersionfig.tex');
filename = sprintf('lrsppdispersionfig.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '11cm', 'width','13cm');
end
%fun = inline('(exp(-4.*k1./e1)-((k1./e1+k2./e2)./(k1./e1-k2./e2)).*((k1./e1+k3./e3)./(k1./e1-k3./e3)))');

% 
% F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
% x = real(out);
% x(x>1000)=0;
% %levels = linspace(mean(x(:))-std(x(:)),mean(x(:))+std(x(:)),10);
% ZC = conv2(x,F,'same');
% ZC = conv2(ZC,F,'same');
% contourf(ZC)
