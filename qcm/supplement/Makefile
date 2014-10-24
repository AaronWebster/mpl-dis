TARGET=supplement

# parallel execution?
NUMJOBS=${NUMJOBS:-" -j4 "}


# You want latexmk to *always* run, because make does not have all the info.
# Also, include non-file targets in .PHONY so they are run regardless of any
# file of the given name existing.
.PHONY: $(TARGET).pdf all clean

# The first rule in a Makefile is the one executed by default ("make"). It
# should always be the "all" rule, so that "make" and "make all" are identical.
all: $(TARGET).pdf 

# build all in figures
# this is done independently to make the submission process easier
figures:
	make -C figures

spell:
	hunspell -t -i utf-8 $(TARGET).tex

# CUSTOM BUILD RULES

# just do a normal pdflatex
quick:
	pdflatex -shell-escape $(TARGET).tex

# In case you didn't know, '$@' is a variable holding the name of the target,
# and '$<' is a variable holding the (first) dependency of a rule.
# "raw2tex" and "dat2tex" are just placeholders for whatever custom steps
# you might have.

commithash.tex:
	git rev-parse HEAD > commithash.tex

#drawing-side-specific.pdf: drawing-side-specific.svg
#	inkscape --export-pdf=$@ $<

#dybwadmodel.pdf: ybwadmodel.svg
#	inkscape --export-pdf=$@ --export-latex $<

#%.pdf: 
#	pdflatex -interaction nonstopmode -shell-escape $(TARGET).tex
#	pdfcrop --pdftex $@ $@

#%.pdf: %.svg
#	inkscape --export-pdf=$@ $<
#	./raw2tex $< > $@
#
#	pdflatex $<
#	pdfcrop --pdftex $@ $@
#	./dat2tex $< > $@
#
# MAIN LATEXMK RULE

# -pdf tells latexmk to generate PDF directly (instead of DVI).
# -pdflatex="" tells latexmk to call a specific backend with specific options.
# -use-make tells latexmk to call make for generating missing files.

# -interaction nonstopmode keeps the pdflatex backend from stopping at a
# missing file reference and interactively asking you for an alternative.

$(TARGET).pdf: $(TARGET).tex figures
	git rev-parse HEAD > commithash.tex
	latexmk -f -pdf -pdflatex="pdflatex -interaction nonstopmode -shell-escape" -use-make $(TARGET).tex 

clean:
	latexmk -CA
	rm -f commithash.tex
	rm -f external/*
	rm -f $(TARGET).auxlock
	rm -f $(TARGET)Notes.bib
	rm -f $(TARGET).bbl
