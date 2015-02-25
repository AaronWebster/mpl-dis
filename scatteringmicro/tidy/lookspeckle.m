nscat = 20
nout = 25;
out = zeros(1,nout);
for j=1:500
	for i=1:nout
		rseed = randi(10000000);
		command = sprintf('./scatter --nscat=%d --MS --random-seed=%d',nscat,rseed);
		system(command);
		a = load('out.dat');
		a = a./trapz(a);
		a = a(100:400);
		command = sprintf('./scatter --nscat=%d --MS --random-seed=%d',nscat+i-1,rseed);
		system(command);
		b = load('out.dat');
		b = b./trapz(a);
		b = b(100:400);
		out(i) = out(i) + 1/(length(a)-1)*sum((a-mean(a)).*(b-mean(b)))/(std(a)*std(b));
end
end

