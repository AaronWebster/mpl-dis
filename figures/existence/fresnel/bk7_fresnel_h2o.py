#!/usr/bin/python

# finds the thickness and angle which give the minimum in the notch

# all kinds of math stuff
from numpy import *
from bb import LDBB
from scipy.optimize import fmin_tnc
import h5py

# dielectric function for BK7
n_BK7 = lambda x:\
sqrt( 1 + 1.03961212*pow(x*1e6,2)/(pow(x*1e6,2)-0.00600069867) +\
0.231792344*pow(x*1e6,2)/(pow(x*1e6,2)-0.0200179144) +\
1.01046945*pow(x*1e6,2)/(pow(x*1e6,2)-103.560653))\

# dielectric function for LAH79, in nanometers
n_LAH79 = lambda x:\
sqrt( 1 + 2.32557148E+00*pow(x*1e6,2)/(pow(x*1e6,2)-1.32895208E-02) +\
5.07967133E-01*pow(x*1e6,2)/(pow(x*1e6,2)-5.28335449E-02) +\
2.43087198E+00*pow(x*1e6,2)/(pow(x*1e6,2)-1.61122408E+02) )

eps_h2o = complex(1.7692,0.051569)

metals = ['Ag', 'Au', 'Cu', 'Al', 'Be', 'Cr', 'Ni', 'Pd', 'Pt', 'Ti', 'W']
# global variables
# wavelength of incident radiation
lambda0 = 632.8e-9

for metal in metals:
	# dielectric properties
	epsilon = array([ n_BK7(lambda0)**2, LDBB(metal,'LD',array([lambda0]))[0], eps_h2o])

	k0 = 2*pi/lambda0
	# z component of k vector
	kz = lambda i,theta : sqrt(k0**2*epsilon[i]-(k0*sqrt(epsilon[0])*sin(theta))**2)
	# reflectivity guys
	r  = lambda i,j,theta : (epsilon[j]*kz(i,theta)-epsilon[i]*kz(j,theta))/(epsilon[j]*kz(i,theta)+epsilon[i]*kz(j,theta)) 
	# combined fresnel relation
	fr123 = lambda x0: abs((r(0,1,x0[0])+r(1,2,x0[0])*exp(2J*kz(1,x0[0])*x0[1]))/(1+r(0,1,x0[0])*r(1,2,x0[0])*exp(2J*kz(1,x0[0])*x0[1])))
	r123 = lambda theta,d: \
	(r(0,1,theta)+r(1,2,theta)*exp(2J*kz(1,theta)*d))/ \
	(1+r(0,1,theta)*r(1,2,theta)*exp(2J*kz(1,theta)*d))

	theta = linspace(0,pi/2,1000)
	dat = [ abs(r123(theta,d)) for d in linspace(0,100e-9,1000) ]

	x0 = array([ pi/4, 50.0e-9 ])
	b = array([[0.0,pi/2],[0.0,100.0e-9]])
	xopt = fmin_tnc(fr123, x0,approx_grad=True,bounds=b,xtol=1e-6,maxfun=1000)
	thetamin = xopt[0][0]
	dmin = xopt[0][1]

	f = open("BK7-fresnel-h2o.txt","a")
	f.write("%s\t%.20g\t%.20g\n" % (metal, thetamin, dmin))
	f.close()

	f = h5py.File('%s_BK7_h2o_6328_0-100_0-90.h5' % metal,'w')
	dset = f.create_dataset("bar",data=dat)
	f.close()
