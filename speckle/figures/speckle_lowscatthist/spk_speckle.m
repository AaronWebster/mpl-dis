clear all;
close all;
addpath('~/mpl-dis/includes')

%% fft method
% size of initial random matrix -- input
N = 10;
% size of padded matrix -- output
M = 200;

% random phasors
a = exp(2.0i*pi.*rand(N,N));

% take fft, shift
a = padarray(a,[M,M],0,'both');
b = fft2(a);
c = abs(b).^2;

d = 1:size(a(:));
d = reshape(d,size(b));
b = b.*(-1).^d;
b = b.*(-1).^d';

% show pattern
mycolor = brewermap(5,'Set1');
colormap(brewermap([],'YlOrRd'))
figure(1)
clf;
subplot(121)
%imagesc(c);
contourf(c)
colorbar('location','southoutside')
set(gca,'XTickLabel','')
set(gca,'YTickLabel','')
set(gca,'ZTickLabel','')

subplot(122);
hold on;
contour(real(b),[0,0],'linecolor',mycolor(2,:));
contour(imag(b),[0,0],'linecolor',mycolor(1,:));
set(gca,'XTickLabel','')
set(gca,'YTickLabel','')
legend('real','imag','location','southoutside','orientation','horizontal')

if false
    filename = sprintf('/tmp/test.tex');
    matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', true, ...
        'height', '9cm', 'width','9cm');
end