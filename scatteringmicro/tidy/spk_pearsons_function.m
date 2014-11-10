function [ C ] = spk_pearsons_function( M, S )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%myrng = rng;
%load('myrng.mat')
%rng(myrng);
%% do calculation
% size of output field
N = 1000;
% spatial extent in real coordinates
ext = 100;
% k vector
k0 = 1;
% set up mesh
x = linspace(-ext/2,ext/2,N);
y = linspace(-ext/2,ext/2,N);
[X,Y] =  meshgrid(x,y);
% complex output field
out = zeros(N,N);
% random scatterers
scatt = (rand(2,M+S).*ext-ext/2);
% add them all up in a very bad way

for i=1:M
    out = out + (1./sqrt(M)).*exp((1.0i.*k0-0.00).*(sqrt((X-scatt(1,i)).^2+(Y-scatt(2,i)).^2)));
end
outa = abs(out).^2;
%mean(outa(:))/std(outa(:))

for i=1:(M+S)
    out = out + (1./sqrt(M+S)).*exp((1.0i.*k0-0.00).*(sqrt((X-scatt(1,i)).^2+(Y-scatt(2,i)).^2)));
end
% get intensity of the field
outb = abs(out).^2;
%mean(outb(:))/std(outb(:))

% figure(1)
% clf;
% subplot(121)
% imagesc(outa)
% subplot(122)
% imagesc(outb)

mean(abs(outa(:)-outb(:)))

tmp = cov(outa,outb);
C = tmp(1,2)/(std(outa(:))*std(outb(:)));
%(1/(M-2))*(1/(M-3))*sum((outa(:)-mean(outa(:))).*(outb(:)-mean(outb(:))))/(std(outa(:))*std(outb(:)))


end

