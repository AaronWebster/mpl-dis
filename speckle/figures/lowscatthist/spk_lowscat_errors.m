
M=6;
[px, py] = spk_analyticdist( M );
s = (1-1/M);
sum(py-1/sqrt(s).*exp(-px./sqrt(s)))^2