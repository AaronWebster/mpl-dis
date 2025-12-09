#!/usr/bin/python

from bb import LDBB
from numpy import *
import sys,os 

metals = [ 'Ag','Al','Au','Cu','Cr','Ni','W','Ti','Be','Pd','Pt' ]
models = ['LD', 'D', 'BB']
#params = [ 'er', 'ei', 'nr', 'ni' ]
#ylabels = ['\\epsilon\'', '\\epsilon\'\'', 'n\'', 'n\'\'' ]
#xlabels = [ '', '', '', 'wavelength (\\si{\\micro\\meter})' ]
#locations = [ 'rt', 'rb', 'rt', 'rb' ]

N=100
lambda0 = linspace(200e-9,2000e-9,N)
data_LD = LDBB(metal,"LD",lambda0)
data_D = LDBB(metal,"D",lambda0)
data_BB = LDBB(metal,"BB",lambda0)

print("\\begin{tabularx}{\\textwidth}{lllllll}")
for l in linspace(200e-9,2000e-9,N):
	pass  # TODO: Complete implementation
	# \multirow{3}{*}{}

# print data pretty like
#def prettyprint(one,two,val):
#	ret = ""
#	for i in range(0,len(one)):
#		if val == "er":
#			print "(%s, %s)" % (one[i], real(two[i]))
#		if val == "ei":
#			print "(%s, %s)" % (one[i], imag(two[i]))
#		q = (1/sqrt(2))*sqrt(sqrt(real(two)**2+imag(two)**2)+real(two)) + 1.0J*sqrt(sqrt(real(two)**2+imag(two)**2)-real(two))
#		if val == "nr":
#			print "(%s, %s)" % (one[i], real(q[i]))
#		if val == "ni":
##			print "(%s, %s)" % (one[i], imag(q[i]))


#for metal in metals:

