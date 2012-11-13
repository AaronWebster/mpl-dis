function [amin,amax] = showwidth(x,y)

# quick calculation of the width for good plot scaling
# basically this script gives you the point on the left of the plot where
# the data is the variable mf (times the maximum value)

mf = 0.0001*max(y);
for i = 1:length(y)
	if y(i)>mf
		#amin = x(i);
		amin = i;
		break;
	endif
endfor

for j = length(y):-1:1
	if y(j)>mf
		#amax = x(j);
		amax = j;
		break;
	endif
endfor

endfunction
