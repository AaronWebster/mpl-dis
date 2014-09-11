c = get_constant('c','SI');
e = get_constant('e','SI');
hbar = get_constant('h','SI')/(2*pi);
omega = linspace(2*pi*c/10000e-9,2*pi*c/300e-9,10000);
e1 = 1;
% no damping
e2 = real(LD(2*pi*c./omega,'Ag','LD'));
% damping
%e2 = LD(2*pi*c./omega,'Ag','LD');
beta = (omega./c).*(sqrt(e1*e2./(e1+e2)));

%wp = 9.01*e/hbar;
plot(real(beta),omega,imag(beta),omega)
%plot(real(beta)./wp,omega./wp,imag(beta)./wp,omega./wp)
axis([0 6e7 1e15 7e15])
%axis([0 8e7 0e15 10e15])
%axis([0 2 0.3 1.1])