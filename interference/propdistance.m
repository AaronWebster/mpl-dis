addpath('~/mpl-dis/includes')
addpath('~/mpl-dis/code/mrf_SPP_speckle')

lambda = 632.8e-9;

e1 = LD(lambda,'Ag','LD')
%e2 = nBK7(lambda)^2
e2 = 1
k0 = 2*pi/lambda;
kx = k0*sqrt((e1*e2)/(e1+e2));
1/(2*imag(kx))
