function [p rsquare] = regression(filename)
	a = load(filename);
	x = a(:,1);
	y = a(:,2);
	% fit polynomial
	p = polyfit(x,y,1);
	% get least squares
	r = corr(x,y).^2;
	plot(x,y,x,polyval(p,x));
	printf("slope:\t%g\n",p(1));
	printf("R^2:\t%g\n",r);

endfunction
