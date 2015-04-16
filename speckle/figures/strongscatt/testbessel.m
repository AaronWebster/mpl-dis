r = 1;
ibar = 1;
x = linspace(0,10,100);
y = (1./ibar).*exp(-1.0.*((x+r)./ibar)).*besseli(0,2.*sqrt(x.*r)./ibar);

figure(1)
plot(x,y)
