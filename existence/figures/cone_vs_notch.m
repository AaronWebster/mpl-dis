% test angular sensitivity

%% initialize variables
clear all;
close all;
addpath('~/mpl-dis/code/mrf_SPP_speckle')
addpath('~/mpl-dis/includes')

% angle range to look at
ta = 55;
tb = 85; 
theta = linspace(ta,tb,10000);

% fresnel r and t for both polarizations
rp1a = zeros(1,length(theta));
rp2a = zeros(1,length(theta));
tp1a = zeros(1,length(theta));
tp2a = zeros(1,length(theta));
rp1b = zeros(1,length(theta));
rp2b = zeros(1,length(theta));
tp1b = zeros(1,length(theta));
tp2b = zeros(1,length(theta));

% wavelength, thicknesses, and refractive indicies
lambda = 660e-9;
k0 = 2*pi/lambda;
n1 = nBK7(lambda);
n2 = sqrt(LD(lambda,'Au','LD'));
n3 = nH20(lambda);
d2 = 45e-9;
nJ = [n1,n2,n3];
dJ = [0,d2,0];
kx0 = k0*n1*sin(deg2rad(theta));

%% calculate angular spectrum
% a -> 123
% b -> 321
% 1 -> dn=0
% 2 -> dn=dn
parfor i=1:length(kx0)
    [Mp, Ms] = transfer_matrix_multi(k0,kx0(i),nJ,dJ);
    [rp1a(i),~,tp1a(i)] = trans_mat_2_fresnel(Mp,Ms);
end

nJ = [n3,n2,n1];
parfor i=1:length(kx0)
    [Mp, Ms] = transfer_matrix_multi(k0,kx0(i),nJ,dJ);
    [rp1b(i),~,tp1b(i)] = trans_mat_2_fresnel(Mp,Ms);
end

% calculate angular spectrum for the refractive index modified one
dn = 0.01;
nJ = [n1,n2,n3+dn];
parfor i=1:length(kx0)
    [Mp, Ms] = transfer_matrix_multi(k0,kx0(i),nJ,dJ);
    [rp2a(i),~,tp2a(i)] = trans_mat_2_fresnel(Mp,Ms);
end

nJ = [n3+dn,n2,n1];
parfor i=1:length(kx0)
    [Mp, Ms] = transfer_matrix_multi(k0,kx0(i),nJ,dJ);
    [rp2b(i),~,tp2b(i)] = trans_mat_2_fresnel(Mp,Ms);
end

RP1a = abs(rp1a).^2;
RP2a = abs(rp2a).^2;
TP1a = abs(tp1a).^2;
TP2a = abs(tp2a).^2;
RP1b = abs(rp1b).^2;
RP2b = abs(rp2b).^2;
TP1b = abs(tp1b).^2;
TP2b = abs(tp2b).^2;
TP1ab = TP1a.*TP1b;
TP2ab = TP2a.*TP2b;

% normalize the transmission to make an intensity comparison
% first scale to [0,1]
tmp = min(TP1ab);
TP1 = TP1ab-tmp;
TP2ab = TP2ab-tmp;
tmp = max(TP1ab);
TP1ab = TP1ab./tmp;
TP2ab = TP2ab./tmp;
% then scale to the range of the specular 
TP1ab = TP1ab.*range(RP1a);
TP2ab = TP2ab.*range(RP1a);
TP1ab = TP1ab+min(RP1a);
TP2ab = TP2ab+min(RP1a);

% fit to spline
%fit spline to the reflectance, calculate dtheta/dn
FR1a = fit(theta',RP1a','smoothingspline');
r1a = fminbnd(FR1a,ta,tb);
FR2a = fit(theta',RP2a','smoothingspline');
r2a = fminbnd(FR2a,ta,tb);

FT1ab = fit(theta',TP1ab','smoothingspline');
%t1ab = fminbnd(FT1ab,ta,tb);
FT2ab = fit(theta',TP2ab','smoothingspline');
%t2ab = fminbnd(FT2ab,ta,tb);



%% plot data
figure(1)
clf;
% choose a new theta with fewer points
theta = linspace(ta,tb,100);
mycolor = brewermap(12,'Paired');
hold on;
plot(theta,FR1a(theta),'Color',mycolor(2,:))
plot(theta,max(RP1a)-FT1ab(theta),'Color',mycolor(6,:))
xlabel('angle $\theta$ [deg]')
ylabel('$|E|^2$ [a.u.]')
legend('notch','cone','Location','SouthWest')

%plot(theta,abs(gradient(RP1a)),theta,abs(gradient(TP1ab)))
%% save to tikz
if false
filename = sprintf('cone_vs_notch.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '5cm', 'width','6.5cm')
end