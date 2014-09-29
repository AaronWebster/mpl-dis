clear all;
close all;

addpath('~/mpl-dis/includes')

% load data files
a = load('zoom-spotsmall');
b = load('zoom-spotmed');
c = load('zoom-spotlarge');
d = load('zoom-spotsize');

% convert guys to double
a.frame_a = double(a.frame_a);
b.frame_a = double(b.frame_a);
c.frame_a = double(c.frame_a);

a.frame_b = double(a.frame_b(300:900,400:1000));
b.frame_b = double(b.frame_b(300:900,400:1000));
c.frame_b = double(c.frame_b(300:900,400:1000));

% normalize images so they plot nicely
%a.frame_a = (min(a.frame_a(:))-a.frame_a)./range(a.frame_a(:));
%b.frame_a = (min(b.frame_a(:))-b.frame_a)./range(b.frame_a(:));
%c.frame_a = (min(c.frame_a(:))-c.frame_a)./range(c.frame_a(:));

%a.frame_b = (min(a.frame_b(:))-a.frame_b)./range(a.frame_b(:));
%b.frame_b = (min(b.frame_b(:))-b.frame_b)./range(b.frame_b(:));
%c.frame_b = (min(c.frame_b(:))-c.frame_b)./range(c.frame_b(:));

figure(1);
clf;
subplot(521)
imagesc(c.frame_b);
axis square;
subplot(522)
imagesc(c.frame_a);

subplot(523)
imagesc(b.frame_b);
axis square;
subplot(524)
imagesc(b.frame_a);

subplot(525)
imagesc(a.frame_b);
axis square;
subplot(526)
imagesc(a.frame_a);

if false
filename = sprintf('/tmp/test.tex');
matlab2tikz(filename, 'showInfo', false, ...
    'parseStrings',false,'standalone', true, ...
        'height', '3.5cm', 'width','9cm');
end

