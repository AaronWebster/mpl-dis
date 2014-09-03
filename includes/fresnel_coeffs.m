function [rp,rs,tp,ts] = fresnel_coeffs(kz1,kz2,n1,n2)
% function [rp,rs,tp,ts] = fresnel_coeffs(kz1,kz2,n1,n2)

rp = -(n1^2 * kz2 - n2^2 * kz1)./(n1^2 * kz2 + n2^2 *kz1);
rs = (kz1 - kz2)./(kz1 + kz2);
tp = 2 * n1 * n2 * kz1 ./ (n1^2 * kz2 + n2^2 * kz1);
ts = 2 *kz1 ./ (kz1 + kz2);