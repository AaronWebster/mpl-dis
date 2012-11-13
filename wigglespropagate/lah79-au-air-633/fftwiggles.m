## -*- texinfo -*-
## @deftypefn  {Function File} {@var{[x,a,b]} =} fftwiggles(@var{z}, @var{eps_delta})
## Computes the wiggle pattern using a fast fourier transform
## 

function [x,rspec,rcone,rgauss] = fftwiggles(z,eps_delta)

# variables
k0=9.9291803210802580537;
theta=0.56021707096540351856;
d=0.043805192427404646138;
epsilon1=3.9845198023240708807+0i;
epsilon2=-9.8001402179372156809+1.9648780628254329805i;
epsilon3=1+0i;

w=4;
wx = w/cos(theta);
spread = 25.0*pi/180;
N = 80000;

# function definitions
kxi = k0*sqrt(epsilon1)*sin(theta);
k1z = @(kx) sqrt(k0.^2*epsilon1-kx.^2);
k2z = @(kx) sqrt(k0.^2*epsilon2-kx.^2);
k3za = @(kx) sqrt(k0.^2*epsilon3-kx.^2);
k3zb = @(kx) sqrt(k0.^2*(epsilon3+eps_delta)-kx.^2);
r12 = @(kx) (epsilon2.*k1z(kx)-epsilon1.*k2z(kx))./(epsilon2.*k1z(kx)+epsilon1.*k2z(kx));
r123a = @(kx) ((1-((k1z(kx).*epsilon2-k2z(kx).*epsilon1)./(k1z(kx).*epsilon2+k2z(kx).*epsilon1)).^2).* ((k2z(kx).*epsilon3-k3za(kx).*epsilon2)./(k2z(kx).*epsilon3+k3za(kx).*epsilon2)).*exp(1.0i.*2.*k2z(kx).*d) ./(1+((k1z(kx).*epsilon2-k2z(kx).*epsilon1)./(k1z(kx).*epsilon2+k2z(kx).*epsilon1)).*((k2z(kx).*epsilon3-k3za(kx).*epsilon2)./(k2z(kx).*epsilon3+k3za(kx).*epsilon2)).*exp(1.0i.*2.*k2z(kx).*d)))+((k1z(kx).*epsilon2-k2z(kx).*epsilon1)./(k1z(kx).*epsilon2+k2z(kx).*epsilon1));
r123b = @(kx) ((1-((k1z(kx).*epsilon2-k2z(kx).*epsilon1)./(k1z(kx).*epsilon2+k2z(kx).*epsilon1)).^2).* ((k2z(kx).*epsilon3-k3zb(kx).*epsilon2)./(k2z(kx).*epsilon3+k3zb(kx).*epsilon2)).*exp(1.0i.*2.*k2z(kx).*d) ./(1+((k1z(kx).*epsilon2-k2z(kx).*epsilon1)./(k1z(kx).*epsilon2+k2z(kx).*epsilon1)).*((k2z(kx).*epsilon3-k3zb(kx).*epsilon2)./(k2z(kx).*epsilon3+k3zb(kx).*epsilon2)).*exp(1.0i.*2.*k2z(kx).*d)))+((k1z(kx).*epsilon2-k2z(kx).*epsilon1)./(k1z(kx).*epsilon2+k2z(kx).*epsilon1));
r321a = @(kx) ((1-((k3za(kx).*epsilon2-k2z(kx).*epsilon3)./(k3za(kx).*epsilon2+k2z(kx).*epsilon3)).^2).* ((k2z(kx).*epsilon1-k1z(kx).*epsilon2)./(k2z(kx).*epsilon1+k1z(kx).*epsilon2)).*exp(1.0i.*2.*k2z(kx).*d) ./(1+((k3za(kx).*epsilon2-k2z(kx).*epsilon3)./(k3za(kx).*epsilon2+k2z(kx).*epsilon3)).*((k2z(kx).*epsilon1-k1z(kx).*epsilon2)./(k2z(kx).*epsilon1+k1z(kx).*epsilon2)).*exp(1.0i.*2.*k2z(kx).*d)))+((k3za(kx).*epsilon2-k2z(kx).*epsilon3)./(k3za(kx).*epsilon2+k2z(kx).*epsilon3));
r321b = @(kx) ((1-((k3zb(kx).*epsilon2-k2z(kx).*epsilon3)./(k3zb(kx).*epsilon2+k2z(kx).*epsilon3)).^2).* ((k2z(kx).*epsilon1-k1z(kx).*epsilon2)./(k2z(kx).*epsilon1+k1z(kx).*epsilon2)).*exp(1.0i.*2.*k2z(kx).*d) ./(1+((k3zb(kx).*epsilon2-k2z(kx).*epsilon3)./(k3zb(kx).*epsilon2+k2z(kx).*epsilon3)).*((k2z(kx).*epsilon1-k1z(kx).*epsilon2)./(k2z(kx).*epsilon1+k1z(kx).*epsilon2)).*exp(1.0i.*2.*k2z(kx).*d)))+((k3zb(kx).*epsilon2-k2z(kx).*epsilon3)./(k3zb(kx).*epsilon2+k2z(kx).*epsilon3));
gausskx = @(kx) exp(-0.25.*(kx-kxi).^2*wx.^2).*wx./sqrt(2);

# k space
k = linspace(k0*sqrt(epsilon1)*sin(theta-spread),k0*sqrt(epsilon1)*sin(theta+spread),N);

# x and y are the actual output
x = [0:N-1].*2.*pi./range(k);
rspec = ifft(1/sqrt(2*pi).*r123a(k).*gausskx(k).*exp(1.0i*sqrt(k0.*k0.*epsilon1-k.*k).*z)).*abs(k(1)-k(2)).*N;
rcone = ifft(1/sqrt(2*pi).*r321b(k).*gausskx(k).*exp(1.0i*sqrt(k0.*k0.*epsilon1-k.*k).*z)).*abs(k(1)-k(2)).*N;
rgauss = ifft(1/sqrt(2*pi).*gausskx(k).*exp(1.0i*sqrt(k0.*k0.*epsilon1-k.*k).*z)).*abs(k(1)-k(2)).*N;

rspec = abs(rspec).^2;
rcone = abs(rcone).^2;
rgauss = abs(rgauss).^2;

endfunction
