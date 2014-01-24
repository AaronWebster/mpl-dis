#!/usr/bin/python

from matplotlib import rc
import matplotlib.pylab as plt
from numpy import *

rc('font', **{'family': 'serif', 'serif': ['Computer Modern'], 'size': 10 })
rc('text', usetex=True)

plt.figure(figsize=(5,3))
x = linspace(0,5)
plt.plot(x,sin(x))
plt.ylabel(r"This is $\sin(x)$")
plt.savefig("out.pdf")
