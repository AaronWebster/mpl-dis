%% find the minimum of the function, theta_sp or k_sp
theta0 = fminbnd(@(x) abs(fresnel_ssp_rp(x,0)).^2,62,64);

%% plot data
N = 1000;
theta = linspace(60,66,N);
k0 = 2*pi/660e-9;
kx = k0*n1*sin(deg2rad(theta));

fresnel_ssp_rp(theta,0)



gausskx = @(kx) exp(-0.25.*(kx-kxi).^2*wx.^2).*wx./sqrt(2);
exp(-(theta-theta0).^2/5)

E_spec = ifft(1/sqrt(2.*pi).*exp(1.0i*sqrt(k0.*k0.*epsilon1-k.*k).*z)).*abs(k(1)-k(2)).*N
out = fft(exp(-(theta-theta0).^2/5).*exp(fresnel_ssp_rp(theta,0));
plot(theta,abs(out).^2)

E_cone = ifft(1/sqrt(2.*pi).*nlayerfresnel(k0,k,fliplr(epsilon),fliplr(d)).*gausskx(k).*exp(1.0i*sqrt(k0.*k0.*epsilon1-k.*k).*z)).*abs(k(1)-k(2)).*N;