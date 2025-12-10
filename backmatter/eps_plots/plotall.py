#!/usr/bin/python

from bb import LDBB
from numpy import *
import sys,os 

metals = [ 'Ag','Al','Au','Cu','Cr','Ni','W','Ti','Be','Pd','Pt' ]
models = ['LD', 'D', 'BB']
params = [ 'er', 'ei', 'nr', 'ni' ]
ylabels = ['permittivity $\\epsilon\'$', 'permittivity $\\epsilon\'\'$', 'refractive index $n\'$', 'refractive index $n\'\'$' ] 
xlabels = [ '', '', '', 'wavelength (\\si{\\micro\\meter})' ]
locations = [ 'rt', 'rb', 'rt', 'rb' ]

# print data pretty like
def prettyprint(one,two,val):
	ret = ""
	for i in range(0,len(one)):
		if val == "er":
			print("(%s, %s)" % (one[i], real(two[i])))
		if val == "ei":
			print("(%s, %s)" % (one[i], imag(two[i])))
		q = (1/sqrt(2))*sqrt(sqrt(real(two)**2+imag(two)**2)+real(two)) + 1.0J*sqrt(sqrt(real(two)**2+imag(two)**2)-real(two))
		if val == "nr":
			print("(%s, %s)" % (one[i], real(q[i])))
		if val == "ni":
			print("(%s, %s)" % (one[i], imag(q[i])))


for metal in metals:
	lambda0 = linspace(200e-9,2000e-9,50);
	data_LD = LDBB(metal,"LD",lambda0)
	data_D = LDBB(metal,"D",lambda0)
	data_BB = LDBB(metal,"BB",lambda0)

	print("\\newpage")
	print("\\subsection{%s}" % metal)
	print("\\begin{figure}[h!]")
	print("\\centering")
	print("\\begin{tabular}{l}")

	for i in range(0,4):
		#print "\\subfigure{"
		print("\\begin{tikzpicture}[baseline,trim axis left]")
		print("\\begin{axis}[xlabel=%s,ylabel=%s]" % (xlabels[3], ylabels[i]))
		print("\\addplot[color=colora] coordinates {")
		prettyprint(lambda0, data_D, params[i])
		print("};") 
		print("\\addlegendentry{D}")
		print("\\addplot[color=colorb] coordinates {")
		prettyprint(lambda0, data_LD, params[i])
		print("};") 
		print("\\addlegendentry{LD}")
		print("\\addplot[color=colorc] coordinates {")
		prettyprint(lambda0, data_BB, params[i])
		print("};") 
		print("\\addlegendentry{BB}")
		print("\\end{axis}")
		print("\\end{tikzpicture}%")
		print("\\\\")
		#print "}"
	print("\\end{tabular}")
	print("\\caption{Complex permittivity $\\epsilon = \\epsilon' + \\mi \\epsilon''$ and refractive index $n = n' + \\mi n''$ for %s based on the Drude (D), Lorentz-Drude (LD), and Brendel-Bormann (BB) models.}" % metal)
	print("\\end{figure}")
	print("\\clearpage")
