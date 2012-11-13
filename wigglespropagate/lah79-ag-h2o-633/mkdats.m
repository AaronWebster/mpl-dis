#!/usr/bin/octave -qf

#mytheta = 0.77706917;
M=8;
out = zeros(1,M);
z = [50,250,500,1000,2500,5000,10000,25000,50000];
letters = ['A','B','C','D','E','F','G','H'];
for i=1:M
	
	# specular direction
	[x,rspec,rcone,rgauss] = fftwiggles(z(i),0);
	
	[a,b] = showwidth(x,rspec);
	x = x(a:b);
	rspec = rspec(a:b);
	rcone = rcone(a:b);
	rgauss = rgauss(a:b);
	xi = linspace(min(x),max(x),1024);
	dx = abs(xi(1)-xi(2));
	rspec = interp1(x,rspec,xi,'spline').*dx;
	rcone = interp1(x,rcone,xi,'spline').*dx;
	rgauss = interp1(x,rgauss,xi,'spline').*dx;
	
	file = sprintf("fresnelpropz%sspec.dat",letters(i));
	sensout = [ xi, rspec ];
	sensout = reshape(sensout, length(xi), 2);
	save(file,'sensout','-ascii')

	file = sprintf("fresnelpropz%scone.dat",letters(i));
	sensout = [ xi, rcone ];
	sensout = reshape(sensout, length(xi), 2);
	save(file,'sensout','-ascii')

	file = sprintf("fresnelpropz%sgauss.dat",letters(i));
	sensout = [ xi, rgauss ];
	sensout = reshape(sensout, length(xi), 2);
	save(file,'sensout','-ascii')

endfor
