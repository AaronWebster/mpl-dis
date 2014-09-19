clear all;
close all;

%% do calculation
% number of scatterers
M=100;
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
scatt = (rand(2,M).*ext*2-ext);
% add them all up in a very ineffient way
for i=1:M
    out = out + (1./sqrt(M)).*exp((1.0i.*k0-0.00).*(sqrt((X-scatt(1,i)).^2+(Y-scatt(2,i)).^2)));
end
% get intensity of the fieldblue
outa = abs(out).^2;
ibar = mean(outa(:));

%% fft method
% size of initial random matrix -- input
N = 10;
% size of padded matrix -- output
M = 1000;

% random phasors
a = exp(2.0i*pi.*rand(N,N));

% take fft, shift
b = fft2(a,M,M);
c = abs(b).^2;

% show pattern
figure(1)
clf;
subplot(121)
imagesc(c);

subplot(122);
hold on;
contour(real(b),[0,0],'linecolor','red');
contour(imag(b),[0,0],'linecolor','blue');