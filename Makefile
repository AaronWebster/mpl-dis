TARGET=mpl-dis

.PHONY: all

all: $(TARGET).pdf

single:
	pdflatex -interaction=nonstopmode -halt-on-error -shell-escape $(TARGET).tex

spell:
	hunspell -l -t -i utf-8 $(TARGET).tex

$(TARGET).pdf: $(TARGET).tex $(shell find . -type f -name "*.tex")
	mkdir -p external
	git rev-parse HEAD > commithash.tex
	latexmk -f -pdf -use-make $(TARGET).tex

# Remove build files plus all the latex turds.
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
