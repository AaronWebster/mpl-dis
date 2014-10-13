% start sim
clear all;
close all;

addpath('~/mpl-dis/includes')
det_scale = 500/133; % scale in microns/px

%% load data files
a = load('zoom-spotsmall');
b = load('zoom-spotmed');
c = load('zoom-spotlarge');
d = load('zoom-spotsize');

%% convert guys to double
a.frame_a = double(a.frame_a);
b.frame_a = double(b.frame_a);
c.frame_a = double(c.frame_a);

a.frame_b = double(a.frame_b(300:900,400:1000));
b.frame_b = double(b.frame_b(300:900,400:1000));
c.frame_b = double(c.frame_b(300:900,400:1000));

%% rough size of the focal spot
tmp = sum(a.frame_b,2);
x = 1:length(tmp);
x = x.*500e-6./133;
F = fit(x',tmp,'gauss1');
size_a = 2*sqrt(log(2))*F.c1;

tmp = sum(b.frame_b,2);
x = 1:length(tmp);
x = x.*500e-6./133;
F = fit(x',tmp,'gauss1');
size_b = 2*sqrt(log(2))*F.c1;

tmp = sum(c.frame_b,2);
x = 1:length(tmp);
x = x.*500e-6./133;
F = fit(x',tmp,'gauss1');
size_c = 2*sqrt(log(2))*F.c1;

% normalize images so they plot nicely
%a.frame_a = (min(a.frame_a(:))-a.frame_a)./range(a.frame_a(:));
%b.frame_a = (min(b.frame_a(:))-b.frame_a)./range(b.frame_a(:));
%c.frame_a = (min(c.frame_a(:))-c.frame_a)./range(c.frame_a(:));

%a.frame_b = (min(a.frame_b(:))-a.frame_b)./range(a.frame_b(:));
%b.frame_b = (min(b.frame_b(:))-b.frame_b)./range(b.frame_b(:));
%c.frame_b = (min(c.frame_b(:))-c.frame_b)./range(c.frame_b(:));

%% do plotting
scale_bx = (0:size(a.frame_b,2)).*(500/133);
scale_by = (0:size(a.frame_b,1)).*(500/133);
scale_ax = (0:size(a.frame_a,2)).*(5.2);
scale_ay = (0:size(a.frame_a,1)).*(5.2);


figure(1);
clf;
subplot(521)
imagesc(scale_bx,scale_by,c.frame_b);
xlabel('$x$ [um]')
ylabel('$y$ [um]')
axis square;
title('haldo')

subplot(522)
imagesc(scale_ax,scale_ay,c.frame_a);
xlabel('$x$ [um]')
ylabel('$y$ [um]')

subplot(523)
imagesc(scale_bx,scale_by,b.frame_b);
xlabel('$x$ [um]')
ylabel('$y$ [um]')
axis square;
subplot(524)
imagesc(scale_ax,scale_ay,b.frame_a);
xlabel('$x$ [um]')
ylabel('$y$ [um]')

subplot(525)
imagesc(scale_bx,scale_by,a.frame_b);
xlabel('$x$ [um]')
ylabel('$y$ [um]')
axis square;
subplot(526)
imagesc(scale_ax,scale_ay,a.frame_a);
xlabel('$x$ [um]')
ylabel('$y$ [um]')

if true
filename = sprintf('/tmp/test.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', true, ...
        'height', '3.5cm', 'width','9cm');
end



