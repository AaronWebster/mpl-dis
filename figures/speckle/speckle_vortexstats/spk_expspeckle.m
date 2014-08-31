load('isum.mat');

isout = sort(isum(:));
xr = 0.32;
idx = find(isout>xr,1);
isout = isout(idx:end);
isout = isout-min(isout(:));

[N,X] = hist(isout(:),100);
N = N./max(N(:));


si = std(isout(:));
mi = mean(isout(:));
X = X./mi;

tmp = exp(-X);

plot(X,N,X,tmp);



out1 = [X' N'];
out2 = [X' tmp'];

save('-ascii','conehistexpraw.dat','isout');
save('-ascii','conehistexp.dat','out1');
save('-ascii','conehisttheory.dat','out2');
