# You want latexmk to *always* run, because make does not have all the info.
# Also, include non-file targets in .PHONY so they are run regardless of any
# file of the given name existing.
.PHONY: all clean

# The first rule in a Makefile is the one executed by default ("make"). It
# should always be the "all" rule, so that "make" and "make all" are identical.
all: table.pdf dybwadmodel.pdf circlefit.pdf loadplot.pdf lowersphere.pdf multisweep.pdf drawing-side-specific.pdf 

# CUSTOM BUILD RULES

# In case you didn't know, '$@' is a variable holding the name of the target,
# and '$<' is a variable holding the (first) dependency of a rule.
# "raw2tex" and "dat2tex" are just placeholders for whatever custom steps
# you might have.
movefigure:
	cp drawing-side-specific.pdf ../figure1.pdf
	cp loadplot.pdf ../figure2.pdf
	cp lowersphere.pdf ../figure3.pdf
	cp circlefit.pdf ../figure4.pdf 
	cp multisweep.pdf ../figure5.pdf

drawing-side-specific.pdf: drawing-side-specific.svg
	inkscape --export-pdf=$@ $<

dybwadmodel.pdf: dybwadmodel.svg
	inkscape --export-pdf=$@ --export-latex $<

# MAIN LATEXMK RULE

# -pdf tells latexmk to generate PDF directly (instead of DVI).
# -pdflatex="" tells latexmk to call a specific backend with specific options.
# -use-make tells latexmk to call make for generating missing files.

# -interaction nonstopmode keeps the pdflatex backend from stopping at a
# missing file reference and interactively asking you for an alternative.
%.pdf: %.tex
	latexmk -pdf -pdflatex="pdflatex -interaction nonstopmode -shell-escape" -use-make $< 
	#pdfcrop --pdftex $@ $@

clean:
	latexmk -CA
