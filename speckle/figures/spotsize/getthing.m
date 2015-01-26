function ret = getthing(d)
dt = linspace(1e-6,2*pi/180,1000);
%d = 300e-6;;
lambda = 660e-9;
u = (d./lambda)*dt;
y = 1+(2.*besselj(1,u)./u).^2;
y = (y-min(y))./range(y);
y = [flip(y(2:end)) y];
dt = [-flip(dt(2:end)) dt];
%plot(dt,y);
F = fit(dt',y','gauss1');
ret = F.c1*180/pi;%.*rad2deg(atan(5.2e-6/0.01));
%idx = find(y<1.5,1);
%ret = dt(idx)*180/pi;
end
