#!/usr/bin/python

from numpy import *
from bb import LDBB
import h5py
import matplotlib.pyplot as plt
from scipy import constants




lambda0 = 632.8e-9

def kx_sp_metal_glass(omega):
	e1 = real(LDBB('BK7','LD',array([2*pi*constants.c/omega]))[0])
	e2 = real(LDBB('Ag','LD',array([2*pi*constants.c/omega]))[0])
	return (omega/constants.c)*sqrt(e1*e2/(e1+e2))

def kx_sp_metal_vacuum(omega):
	e1 = 1.0
	e2 = real(LDBB('Ag','LD',array([2*pi*constants.c/omega]))[0])
	return (omega/constants.c)*sqrt(e1*e2/(e1+e2))

def kx_photon_glass(omega):
	e1 = real(LDBB('BK7','LD',array([2*pi*constants.c/omega]))[0])
	return sqrt(e1)*omega/constants.c

def kx_photon_vacuum(omega):
	e1 = 1.0
	return sqrt(e1)*omega/constants.c

def kx_photon_glass_tilted(omega):
	e1 = real(LDBB('BK7','LD',array([2*pi*constants.c/omega]))[0])
	return sqrt(e1)*omega/(constants.c*sin(0.77))

#e1 = real(LDBB('BK7','LD',array([lambda0]))[0])
wp = (9.01*constants.e/constants.hbar)
#(sqrt(1.0+e1))

omega = linspace(2*pi*constants.c/2000e-9,2*pi*constants.c/300e-9,1000)
f1 = [ kx_sp_metal_glass(x) for x in omega ]
f2 = [ kx_sp_metal_vacuum(x) for x in omega ]
f3 = [ kx_photon_vacuum(x) for x in omega ]
f4 = [ kx_photon_glass(x) for x in omega ]
f5 = [ kx_photon_glass_tilted(x) for x in omega ]

f = open("kx_sp_metal_glass.dat",'w')
for i in range(0,len(omega)):
	f.write("%.20g\t%.20g\n" % (f1[i], omega[i]))
f.close()

f = open("kx_sp_metal_vacuum.dat",'w')
for i in range(0,len(omega)):
	f.write("%.20g\t%.20g\n" % (f2[i], omega[i]))
f.close()

f = open("kx_photon_vacuum.dat",'w')
for i in range(0,len(omega)):
	f.write("%.20g\t%.20g\n" % (f3[i], omega[i]))
f.close()

f = open("kx_photon_glass.dat",'w')
for i in range(0,len(omega)):
	f.write("%.20g\t%.20g\n" % (f4[i], omega[i]))
f.close()

f = open("kx_photon_glass_tilted.dat",'w')
for i in range(0,len(omega)):
	f.write("%.20g\t%.20g\n" % (f5[i], omega[i]))
f.close()

#plt.plot(f1,omega,f2,omega)
#plt.plot(omega,f1,omega,f2,omega,f3,omega,f4,omega,f5)
#plt.plot(f1,omega,f2,omega,f3,omega,f4,omega,f5,omega)
#plt.show()
