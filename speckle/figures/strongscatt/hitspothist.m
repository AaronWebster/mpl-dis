clear all;
close all;

addpath('~/mpl-dis/includes')
bright = load('values-bright.txt');
bright = bright(:,2);
dark = load('values-dark.txt');
dark = dark(:,2);
ibarbright = mean(bright);
ibardark = mean(dark);

bright = bright./ibarbright;
dark = dark./ibardark;

spotdark = imread('spot_dark.png');
spotbright = imread('spot_bright.png');
scale_bx = (0:size(spotdark,2)).*(500/133);
scale_by = (0:size(spotdark,1)).*(500/133);
% scale_ax = (0:size(a.frame_a,2)).*(5.2);
% scale_ay = (0:size(a.frame_a,1)).*(5.2);


figure(1)
subplot(211)
hold on;
[nelements,centers]=hist(bright,50);
nelements = nelements./trapz(centers,nelements);
mycolor = brewermap(4,'Blues');
bar(centers,nelements,'BarWidth',1,'FaceColor',mycolor(1,:),'EdgeColor',mycolor(4,:));
ylabel('$\bar{I}p_I(I/\bar{I})$')
xlabel('$I/\bar{I}$')
legend('experiment')
subplot(212)
imagesc(scale_bx, scale_by, spotbright)
xlabel('$x$ [um]')
ylabel('$y$ [um]')


figure(2)
subplot(211)
hold on;
[nelements,centers]=hist(dark,50);
nelements = nelements./trapz(centers,nelements);
mycolor = brewermap(4,'Blues');
bar(centers,nelements,'BarWidth',1,'FaceColor',mycolor(1,:),'EdgeColor',mycolor(4,:));

mult = 4.0;
px = linspace(0,10,100);
py = 1./sqrt(ibarbright).*exp(-px./ibarbright - mult).*2.*1.*sqrt(px./ibarbright.*mult);
plot(px,py,'k--');

ylabel('$\bar{I}p_I(I/\bar{I})$')
xlabel('$I/\bar{I}$')
legend('experiment')
subplot(212)
imagesc(scale_bx, scale_by, spotdark)
xlabel('$x$ [um]')
ylabel('$y$ [um]')


if false
filename = sprintf('spk_hist_%d.tex',M);
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '4cm', 'width','7cm');
end
