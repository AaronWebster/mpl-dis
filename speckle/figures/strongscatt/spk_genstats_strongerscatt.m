clear all;
close all;
%myrng = rng;
%save myrng;
load('myrng.mat')
rng(myrng);
%% do calculation
% number of scatterers
M=10;
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

for i=2:M
    out = out + (1./sqrt(M)).*exp((1.0i.*k0-0.00).*(sqrt((X-scatt(1,i)).^2+(Y-scatt(2,i)).^2)));
end

outa = abs(out).^2;
ibar = mean(outa(:));

r = 4;
mult=sqrt(r.*M);;
i=1;
out = out + (mult./sqrt(M)).*exp((1.0i.*k0-0.00).*(sqrt((X-scatt(1,i)).^2+(Y-scatt(2,i)).^2)));

% get intensity of the field
outa = abs(out).^2;
ibar = mean(outa(:));

%% histogram and analytic plot
figure(1);
clf; cla;
%set(gcf,'Units','normalized')
%set(gcf,'Position',[0,0,0.5,0.5]);
%figure('units','normlized','position',[.1 .1 .4 .4])
subplot(121);
hold on;
[nelements,centers]=hist(outa(:),50);
nelements = nelements./trapz(centers,nelements);
mycolor = brewermap(4,'Blues');
bar(centers,nelements,'BarWidth',1,'FaceColor',mycolor(1,:),'EdgeColor',mycolor(4,:));

% analytic plot with histogram
mycolor = brewermap(4,'Greens');
[px, py] = spk_analyticdist( M );
plot(px,py,'Color',mycolor(4,:));

px = linspace(0,max(centers),100);
py = exp(-(px+r)).*besseli(0,2.0.*sqrt(px.*r));
plot(px,py);
ylabel('$\bar{I}p_I(I/\bar{I})$')
xlabel('$I/\bar{I}$')
legend('simulated','analytic','$N=\infty$')
text(2,0.5,sprintf('$N=%d$, $r=%d$',M,r));
axis([0 10 0 1])

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
scatter(scatt(1,2:end),scatt(2,2:end),'k','LineWidth',2)
scatter(scatt(1,1),scatt(2,1),'k','LineWidth',5)
axis([0 N 0 N],'square')
xlabel('x')
ylabel('y')
hold off;

if true
filename = sprintf('spk_hist_strongscatt_%d.tex',r);
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '4cm', 'width','7cm');
filename = sprintf('spk_hist_strongscatt_%d.mat',r);
save(filename,'outa')
end
