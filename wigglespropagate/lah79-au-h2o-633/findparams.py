#!/usr/bin/python

# finds the thickness and angle which give the minimum in the notch

# all kinds of math stuff
from numpy import *
from scipy.optimize import fmin
import matplotlib.pyplot as plt
from bb import LDBB, sellmeier

# fast routine to detect peaks
from peakdetect import peakdetect

# global variables
# dielectric properties
lambda0 = 632.8e-9
epsilon = array([ sellmeier('LAH79',lambda0)**2, LDBB('Au','LD',array([lambda0]))[0], 1.33169**2 ])
print epsilon

# wavelength of incident radiation
lambda0 = 632.8
# thickness of metal film
d = 54.5

k0 = 2*pi/lambda0
# z component of k vector
kz = lambda i,theta : sqrt(k0**2*epsilon[i]-(k0*sqrt(epsilon[0])*sin(theta))**2)
# reflectivity guys
r  = lambda i,j,theta : (epsilon[j]*kz(i,theta)-epsilon[i]*kz(j,theta))/(epsilon[j]*kz(i,theta)+epsilon[i]*kz(j,theta)) 
# combined fresnel relation
r123 = lambda x0: abs((r(0,1,x0[0])+r(1,2,x0[0])*exp(2J*kz(1,x0[0])*x0[1]))/(1+r(0,1,x0[0])*r(1,2,x0[0])*exp(2J*kz(1,x0[0])*x0[1])))
sr123 = lambda x0: abs((r(0,1,x0)+r(1,2,x0)*exp(2J*kz(1,x0)*50))/(1+r(0,1,x0)*r(1,2,x0)*exp(2J*kz(1,x0)*50)))
f123 = lambda theta,d: \
(r(0,1,theta)+r(1,2,theta)*exp(2J*kz(1,theta)*d))/ \
(1+r(0,1,theta)*r(1,2,theta)*exp(2J*kz(1,theta)*d))

#theta = linspace(0,pi/2,1000)
#plt.plot(theta,abs(f123(theta,50)))
#plt.show()


x0 = [ 0.57, 42 ]
xopt = fmin(r123, x0, xtol=1e-9)
print "k0=%.20g;" % (2*pi/(lambda0*1e-3))
print "theta=%.20g;" % xopt[0]
print "d=%.20g;" % (xopt[1]*1e-3)
print "epsilon1=%.20g+%.20gi;" % (real(epsilon[0]),imag(epsilon[0]))
print "epsilon2=%.20g+%.20gi;" % (real(epsilon[1]),imag(epsilon[1]))
print "epsilon3=%.20g+%.20gi;" % (real(epsilon[2]),imag(epsilon[2]))

