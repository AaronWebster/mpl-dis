function [ x,y ] = restrictrange( in, a, b )
%restricts the range of matrix x to the range a and b
%   quick hack, do not use

x = in(:,1);
y = in(:,2);

idxa = find(x>a,1);
idxb = find(x>b,1);
x = x(idxa:idxb);
y = y(idxa:idxb);

%y = (y-min(y))./range(y);


end

