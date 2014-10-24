function bump(filenamein)
	a = load(filenamein);
	figure(3)
	plot(a(:,1),a(:,2));
	b = sortrows(a,1);
	x = b(:,1);
	y = b(:,2);
	% number of points you want total
	npoints = 10;
	step = max(x)/npoints;

	out = zeros(npoints,4);
	for i=0:npoints-1
		a = find(x>(i*step),1);
		b = find(x>(i+1)*step,1);
		if(length(b)==0)
			b = length(x);
		end
		mx = mean(x(a:b));
		my = mean(y(a:b));
		ex = std(x(a:b));
		ey = std(y(a:b));

		%mx = mean(x(ceil(i*step+1):ceil((i+1)*step)));
		%ex = std(x(ceil(i*step+1):ceil((i+1)*step)));
		%my = mean(y(ceil(i*step+1):ceil((i+1)*step)));
		%ey = std(y(ceil(i*step+1):ceil((i+1)*step)));
		out(i+1,:)=[mx my ey ex];
	end

	figure(1);
	%out(end,2) = out(end,2)-3.31;
	%out(end-1,2) = out(end-1,2)-3.31;
	out(:,2)=out(:,2)-out(1,2);
	plot(out(:,1),out(:,2),x,y);
	figure(2);
	errorbar(out(:,1),out(:,2),out(:,3));
	filenameout = sprintf("%s-ebar.txt",filenamein(1:end-4));
	save('-ascii',filenameout,'out');
end
