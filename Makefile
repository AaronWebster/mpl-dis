TARGET=mpl-dis

.PHONY: all

all: $(TARGET).pdf

#figures:
#	make -C figures

#spell:
#	hunspell -l -t -i utf-8 $(TARGET).tex

# svg figures which should be latex'd
#%.pdf_tex: $(shell find figures -type f -name "*.svg")
#	inkscape --export-pdf=figures/$(@:.pdf_tex=.pdf) --export-latex $<

$(TARGET).pdf: $(TARGET).tex $(shell find . -type f -name "*.tex")
	mkdir -p external
	git rev-parse HEAD > commithash.tex
	latexmk -f -pdf -pdflatex="pdflatex -interaction nonstopmode -shell-escape" -use-make $(TARGET).tex

# remove build files plus all the latex turds
clean:
	latexmk -CA
	mkdir -p external
	rm -f commithash.tex
	rm -rf external/*
	rm -f $(TARGET)Notes.bib
	rm -f $(TARGET).bbl
	rm -f $(TARGET).tdo
	rm -f $(TARGET).figlist
	rm -f $(TARGET).makefile
	rm -f $(TARGET).auxlock
	rm -f $(TARGET).pyg
