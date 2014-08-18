load('isum.mat');

%hist(isum(:),100);
[N,X] = hist(isum(:),100);

N = N./max(N(:));
[x,ix] = max(N(:));
X = X-X(ix);

%isum(isum>X(ix)) = [];

si = std(isum(:));
mi = mean(isum(:));

plot(X,N,X,exp(-X./mean(isum(:))));
