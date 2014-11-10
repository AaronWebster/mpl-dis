% looks at transmission fluctuations from the monte carlo simulation

dir = 'onlyss'
% angle around the ring in degrees
phi = 1:360;

% start and end scatterer index
M=10;
N=30;
%out = zeros(1,N-M);
j=1;
for i=M:N
    filename = sprintf('%s%d/phi.dat',dir,M);
    a = load(filename);
    filename = sprintf('%s%d/phi.dat',dir,i);
    b = load(filename);
    out(j) = mean((a-b).^2/i.^2);
    j = j+1;
end
x = M:N;
plot(out)
%plot(x,a,x,b)