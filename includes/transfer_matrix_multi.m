function [Mp, Ms] = transfer_matrix_multi(k0,kx0,nJ, dJ)
% function [Mp, Ms] = transfer_matrix_multi(k0,kx0,nJ, dJ)

Mp = [1,0;
      0,1];
Ms = Mp;
 
kz = sqrt( (nJ * k0).^2 - kx0^2);

for jj = 1:(numel(dJ)-1)
    [Cjp Cjs] = transfer_matrix_single(kz(jj),kz(jj+1),nJ(jj),nJ(jj+1),dJ(jj));
    
    Mp = Mp * Cjp;
    Ms = Ms * Cjs;
end

Mp = Mp * [exp(-1i*kz(end)*dJ(end)) , 0;
            0, exp(1i*kz(end)*dJ(end))];