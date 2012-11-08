#!/usr/bin/python

from scipy import constants
from bb import LDBB
from numpy import *

lambda0 = array([632.8e-9])
metals = ['Ag', 'Au', 'Cu', 'Al', 'Be', 'Cr', 'Ni', 'Pd', 'Pt', 'Ti', 'W']
models = ['LD', 'D', 'BB']

for metal in metals:
	print "\\multirow{3}{*}{%s}" % metal
	for model in models:
		e2 = 1.0
		e1 = LDBB(metal,model,lambda0)[0]

		kx = ((2.0*pi/lambda0[0])*sqrt(e1*e2/(e1+e2)))
		# kz is the evanescent field decay into each material, 1/e
		kz1 = abs(1/imag((2*pi/lambda0)*e1/sqrt(e1+e2)));
		kz2 = abs(1/imag((2*pi/lambda0)*e2/sqrt(e1+e2)));

		# surface plasmon wavelength
		lambda_sp = real(((1/lambda0)*sqrt(e1*e2/(e1+e2))))**-1;
		
		# 1/e propagation length
		prop_sp = 1/(2*imag(kx));

		# put it in nanometers
		lambda_sp = lambda_sp*1e9
		prop_sp = prop_sp*1e9
		kx = kx*1e9
		kz1 = kz1*1e9
		kz2 = kz2*1e9

		if imag(e1) < 0:
			print " &%s&\\num{%.20g%.20gi}&\\num{%.20g}&\\num{%.20g}&\\num{%.20g}&\\num{%.20g}\\\\" % (model, real(e1), imag(e1), lambda_sp, prop_sp, kz1, kz2)
		else:
			print " &%s&\\num{%.20g+%.20gi}&\\num{%.20g}&\\num{%.20g}&\\num{%.20g}&\\num{%.20g}\\\\" % (model, real(e1), imag(e1), lambda_sp, prop_sp, kz1, kz2)
	print "\\midrule"
