function  [px, py] = spk_analyticdist( N )
%SPK_ANALYTICDIST( N ) Generates analytic distribution of intensity PDF for
%small numbers of scatterers, neglecting multiple scattering.
%   N is the number of scatterers, or random phasors, you want in the sum.
%
%
%   The plots should resemble those of "Speckle Phenomena in Optics", by JW
%   Goodman, page 36 (ISBN13 978-1-936221-14-1)

% first try to load the file if it already exists
filename = sprintf('spk_pdf_smallscatt%d.mat',N);
try
    load(filename);
catch
    
    % intensity of each scatterer
    a = 1;
    
    % number of samples in the distribution space
    Nsamples = 100;
    
    px = zeros(1,Nsamples);
    py = zeros(1,Nsamples);
    i = 1;
    for A = linspace(0,10,Nsamples)
        fun = @(rho) 2.*pi.^2.*rho.*besselj(0,2.*pi.*a.*rho./sqrt(N)).^N.*besselj(0,2.*pi.*sqrt(A).*rho);
        py(i) = quadgk(fun,0,5000,'RelTol',1e-9,'AbsTol',1e-9,'MaxIntervalCount',1e6);
        px(i) = A;
        i = i+1;
    end
    save(filename,'px','py');
end

end