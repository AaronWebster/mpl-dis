clear all;
close all;

addpath('~/mpl-dis/includes')
bright = load('values-bright.txt');
bright = double(bright(:,2));
dark = load('values-dark.txt');
dark = double(dark(:,2));

bright = bright./max(dark(:));
dark = dark./max(dark(:));

ibarbright = mean(dark);
ibardark = mean(dark);

dark = dark./ibardark;
bright = bright./ibardark;

mean(bright)
mean(dark)

r=10;
spotdark = imread('spot_dark.png');
spotbright = imread('spot_bright.png');
scale_bx = (0:size(spotdark,2)).*(500/133);
scale_by = (0:size(spotdark,1)).*(500/133);
% scale_ax = (0:size(a.frame_a,2)).*(5.2);
% scale_ay = (0:size(a.frame_a,1)).*(5.2);


px = linspace(0,30,100);
figure(1)
subplot(421)
hold on;
[nelements,centers]=hist(bright,30);
nelements = nelements./trapz(centers,nelements);
mycolor = brewermap(4,'Blues');
bar(centers,nelements,'BarWidth',1,'FaceColor',mycolor(1,:),'EdgeColor',mycolor(4,:));
ylabel('$\bar{I}p_I(I/\bar{I})$')
xlabel('$I/\bar{I}$')

mycolor = brewermap(4,'Greens');
% py = exp(-(px+0)).*besseli(0,2.0.*sqrt(px.*0));
% plot(px,py,'Color',mycolor(4,:));
py = exp(-(px+r)).*besseli(0,2.0.*sqrt(px.*r));
plot(px,py, 'Color', mycolor(4,:));
legend('experiment','$r$=10')
% axis([0 3 0 1])

subplot(423)
imagesc(scale_bx, scale_by, spotbright)
save('-v7.3','spotbright.mat','spotbright')
xlabel('$x$ [um]')
ylabel('$y$ [um]')

subplot(422)
hold on;
[nelements,centers]=hist(dark,30);
nelements = nelements./trapz(centers,nelements);
mycolor = brewermap(4,'Blues');
bar(centers,nelements,'BarWidth',1,'FaceColor',mycolor(1,:),'EdgeColor',mycolor(4,:));

mycolor = brewermap(4,'Greens');
py = exp(-(px+0)).*besseli(0,2.0.*sqrt(px.*0));
plot(px,py,'Color',mycolor(4,:));

% py = exp(-(px+r)).*besseli(0,2.0.*sqrt(px.*r));
% plot(px,py);
% ylabel('$\bar{I}p_I(I/\bar{I})$')
% xlabel('$I/\bar{I}$')
legend('experiment','$r$=0')
axis([0 10 0 1])

subplot(424)
imagesc(scale_bx, scale_by, spotdark)
save('-v7.3','spotdark.mat','spotdark')
xlabel('$x$ [um]')
% ylabel('$y$ [um]')

if true
filename = sprintf('exp_strongscatt_both_one.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', true, ...
        'height', '3cm', 'width','6cm');
end

if true
filename = sprintf('exp_strongscatt_both_two.tex');
matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '3cm', 'width','6cm');
end

