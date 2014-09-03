function ncyt = nCYT(lambda)
% function ncyt = nCYT(lambda)

if lambda < 0.40978
	ncyt = 1.34886;
else
	cyta = load('./cyt-mikes.dat');
	cytx = cyta(:,1)*1e-9;
	cyty = cyta(:,2);
	ncyt = interp1(cytx,cyty,lambda);
end

