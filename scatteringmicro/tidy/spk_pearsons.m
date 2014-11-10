clear all;
close all;

N = 10;
x = zeros(1,N);
y = zeros(1,N);
j = 1;
for i=1:N
    x(j) = i;
    for k=1:2
        y(j) = y(j) + spk_pearsons_function(20,i);
    end
    y(j) = y(j)/2;
    j = j+1;
end