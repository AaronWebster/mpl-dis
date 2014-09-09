%% away we go
%addpath('~/mpl-dis/includes');
N=500;
theta = linspace(48.78,74.65,500);
lambda = linspace(275e-9,1250e-9,500);

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
        d2 = 1164e-9;
        d3 = 16.97e-9;
        nJ = [n1,n2,n3,n4];
        dJ = [0,d2,d3,0];
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

save('-v7.3','fresnelsppA.mat','theta','lambda','rp')

%% save to file
% filename = sprintf('fresnellrsppfig.tex');
% matlab2tikz(filename, 'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '9cm', 'width','9cm');
