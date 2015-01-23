addpath('~/mpl-dis/includes')
a = imread('before_a.tif');
b = imread('before_a-1.tif');
figure(1)
subplot(2,1,1)
imagesc(a)
set(gca, 'XTickLabel', []);
set(gca, 'YTickLabel', []);
axis image;

subplot(2,1,2)
imagesc(b)
set(gca, 'XTickLabel', []);
set(gca, 'YTickLabel', []);
axis image;

filename = sprintf('/tmp/extractspkline.tex');
matlab2tikz(filename, 'showInfo', true, ...
        'parseStrings',false,'standalone', true, ...
        'height', '4cm', 'width','12cm');
