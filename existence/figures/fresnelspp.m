%% away we go
clear all;
close all;
%addpath('~/mpl-dis/includes');
N=500;
theta = linspace(50,85,500);
lambda = linspace(300e-9,1200e-9,500);

rp = zeros(length(theta),length(lambda));
rs = zeros(length(theta),length(lambda));
tp = zeros(length(theta),length(lambda));
ts = zeros(length(theta),length(lambda));
for i=1:length(theta)
    t = theta(i);
    parfor j=1:length(lambda)
        k0 = 2*pi/lambda(j);
        n1 = nBK7(lambda(j));
        n2 = nCYT(lambda(j));
        n3 = sqrt(LD(lambda(j),'Au','LD'));
        n4 = nH20(lambda(j));
        d2 = 45e-9;
        nJ = [n1,n3,n4];
        dJ = [0,d2,0];
        kx0 = k0*n1*sin(deg2rad(t));
        [Mp, Ms] = transfer_matrix_multi(k0,kx0,nJ,dJ);
        [rp(j,i)] = trans_mat_2_fresnel(Mp,Ms);
    end
    i/length(theta)
end

%% plot
figure(1)
clf;
colormap(brewermap([],'YlOrRd'));
imagesc(theta,lambda,abs(flipud(rp)).^2)
set(gca,'YDir','normal')
xlabel('$\theta$ [degrees]')
ylabel('$\lambda$ [m]')
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String', '$|r_p|^2$');

save('-v7.3','fresnelsppB.mat','theta','lambda','rp')

%% save to file
% filename = sprintf('fresnelsppfig.tex');
% matlab2tikz(filename, 'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '9cm', 'width','9cm');
