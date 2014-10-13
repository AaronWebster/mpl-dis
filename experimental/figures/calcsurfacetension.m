% http://ddbonline.ddbst.de/DIPPR106SFTCalculation/DIPPR106SFTCalculationCGI.exe 
Facetone = fit(acetone(:,1),acetone(:,2),'smoothingspline');
Fwater = fit(water(:,1),water(:,2),'smoothingspline');

Facetone(20)
Fwater(20)
