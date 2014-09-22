% code to generate speckle with the fourier transform method

% size of initial random matrix -- input
N = 10;
% size of padded matrix -- output
M = 1000;

% random phasors
a = exp(2.0i*pi.*rand(N,N));

% take fft, shift
b = fft2(a,M,M);
c = fftshift(abs(b).^2);

% show pattern
figure(1)
imagesc(c);

% histogram of intensity
figure(2)
hist(c(:),50);

% display mean and std
mean(c(:))
std(c(:))

% write the speckle to an hdf5 file
filename = 'speckle.h5';
h5create(filename,'/e2',size(c));
h5write(filename, '/e2', c);

