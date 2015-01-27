% spot size plot
% data generated on lab in /mnt/disk0/lookimg/calcSpeckleSize.m

% sizes of speckle things
% size_a =   1.0233e-04
% size_b =   3.6494e-04
% size_c =   5.9930e-04

clear all;
close all;
addpath('~/mpl-dis/includes')

load('fixedplot.mat');

a = load('zoom-spotsmall');
b = load('zoom-spotmed');
c = load('zoom-spotlarge');

a.frame_a = double(a.frame_a);
b.frame_a = double(b.frame_a);
c.frame_a = double(c.frame_a);

a.frame_b = double(a.frame_b(300:900,400:1000));
b.frame_b = double(b.frame_b(300:900,400:1000));
c.frame_b = double(c.frame_b(300:900,400:1000));

scale_bx = (0:size(a.frame_b,2)).*(500/133);
scale_by = (0:size(a.frame_b,1)).*(500/133);
scale_ax = (0:size(a.frame_a,2)).*(5.2);
scale_ay = (0:size(a.frame_a,1)).*(5.2);

F = fit(x,y,'poly1');
figure(1)
clf;
hold on;
%y = y./div;
mycolor = brewermap(5,'Set1');
plot(x,y,'-','Color',mycolor(2,:));
%plot(x,F(x),'--','Color',mycolor(1,:));

out = zeros(length(x),1);
i = 1;
for d = linspace(min(x),max(x),100)
	out(i) = getthing(d.*1e-6);
	i = i+1;
end
d = linspace(min(x),max(x),100);
plot(d,out,'--','Color',mycolor(1,:));
%plot(x,660e-9*1.5e-3./(x*1e-6./2))

xlabel('reference spot size [um]');
ylabel('speckle size [deg]');
axis([100 450 mean(y)-0.1 mean(y)+0.1 ])
legend('speckle size (experiment)','objective speckles (theory)');

% axes('Position',[.7 .7 .2 .2])
% imagesc(scale_bx,scale_by,a.frame_b);
% xlabel('$x$ [um]')
% ylabel('$y$ [um]')
% axis square;
% 
% axes('Position',[.5 .7 .2 .2])
% imagesc(scale_bx,scale_by,b.frame_b);
% xlabel('$x$ [um]')
% ylabel('$y$ [um]')
% axis square;
% 
% axes('Position',[0.2 .7 .2 .2])
% imagesc(scale_bx,scale_by,c.frame_b);
% xlabel('$x$ [um]')
% ylabel('$y$ [um]')
% axis square;


if true
    filename = sprintf('spotsizefig.tex');
    %filename = sprintf('/tmp/test.tex');
    matlab2tikz(filename, 'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '3.5cm', 'width','9cm');
end
