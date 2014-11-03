% changes separation into contact radius
function out = mkradius(filename,diameter)
	a = load(filename);
	r = sqrt(diameter-a(:,1)).*sqrt(a(:,1));
	r = real(r)-imag(r);
	f = a(:,2);
	g = a(:,3);
	plot(r,f);
end
