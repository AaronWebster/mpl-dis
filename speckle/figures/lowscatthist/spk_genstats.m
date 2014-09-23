clear all;
close all;

%% do calculation
% number of scatterers
M=2;
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
scatt = (rand(2,M).*ext-ext/2);
% add them all up in a very ineffient way
for i=1:M
    out = out + (1./sqrt(M)).*exp((1.0i.*k0-0.00).*(sqrt((X-scatt(1,i)).^2+(Y-scatt(2,i)).^2)));
end
% get intensity of the field
outa = abs(out).^2;
ibar = mean(outa(:));
%outa = outa./ibar;

%% histogram and analytic plot
figure(1);
%set(gcf,'Units','normalized') 
%set(gcf,'Position',[0,0,0.5,0.5]);
%figure('units','normlized','position',[.1 .1 .4 .4])
subplot(121);
hold on;
[nelements,centers]=hist(outa(:),50);
nelements = nelements./trapz(centers,nelements);
mycolor = brewermap(4,'Blues');
bar(centers,nelements.*ibar,'BarWidth',1,'FaceColor',mycolor(1,:),'EdgeColor',mycolor(4,:));

% analytic plot with histogram
mycolor = brewermap(4,'Greens');
[px, py] = spk_analyticdist( M );
plot(px,py,'Color',mycolor(4,:));

s = (1-1/M);
plot(px,1/sqrt(s).*exp(-px./sqrt(s)),'k--');
hold off;
ylabel('$\bar{I}p_I(I/\bar{I})$')
xlabel('$I/\bar{I}$')
legend('simulated','analytic','$N=\infty$')
text(1,1,sprintf('$N=%d$',M));
axis([0 3 0 1.5])

%% intensity plot with scatterers
subplot(122);
hold on;
colormap(brewermap([],'YlOrRd'))
imagesc(outa./ibar);
h = colorbar;
title(h,'$I/\bar{I}$')
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
scatt = (scatt+ext/2).*(N/ext);
scatter(scatt(1,:),scatt(2,:),'k','LineWidth',2)
axis([0 N 0 N],'square')
xlabel('x')
ylabel('y')
hold off;

if true
filename = sprintf('spk_hist_%d.tex',M);
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '4cm', 'width','7cm');
end
% figure(3);
% clf;
% outf = fftshift(abs(fft2(outa)).^2);
% %outf(495:505,495:505)=0;
% imagesc(log(outf))
% t = linspace(0,2*pi,100);
% hold on;
% x = 100/(2*pi).*sin(t)+501;
% y = 100/(2*pi).*cos(t)+501;
% plot(x,y);
% x = 100/(pi).*sin(t)+501;
% y = 100/(pi).*cos(t)+501;
% plot(x,y);
% axis([420 580 420 580])
% hold off;

% write everything to an HDF file for plotting later
% filename = sprintf('spk_stats_scatt_%d.h5',M);
% h5create(filename,'/Er',size(out));
% h5write(filename,'/Er',real(out));
% 
% h5create(filename,'/Ei',size(out));
% h5write(filename,'/Ei',imag(out));
% 
% h5create(filename,'/I',size(outa));
% h5write(filename,'/I',outa);
% 
% h5create(filename,'/scatt',size(scatt));
% h5write(filename,'/scatt',scatt);
% 
% h5create(filename,'/ext',size(ext));
% h5write(filename,'/ext',ext);
