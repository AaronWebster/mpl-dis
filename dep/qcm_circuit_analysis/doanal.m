#!/usr/bin/octave -qf
[data,colnames,struct] = spice_readfile("test.raw");
freq = data(:,1);
v1 = data(:,2);
v2 = data(:,3);
v3 = data(:,4);
v4 = data(:,5);
i1 = data(:,6);
i2 = data(:,7);


%output_precision(20)
%x = real(a(:,1));
#y = abs(a(:,5)).^2;
%y = abs(a(:,5)).^2;
%[xx,yy]=max(y);
%x(yy)
%[max,min]=peakdet(y,0.01,x);
%max(1)
%figure(1)
%plot(x,abs(a(:,2)).^2,x,abs(a(:,3)).^2,x,abs(a(:,4)).^2);
%plot(x,real(a(:,5)),x,imag(a(:,5)));
