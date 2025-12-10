TARGET=mpl-dis

.PHONY: all

all: $(TARGET).pdf

single:
	pdflatex -interaction=nonstopmode -halt-on-error -shell-escape $(TARGET).tex

spell:
	hunspell -l -t -i utf-8 $(TARGET).tex

$(TARGET).pdf: $(TARGET).tex $(shell find . -type f -name "*.tex") qcm-figures
	mkdir -p external
	git rev-parse HEAD > commithash.tex
	latexmk -f -pdf -use-make $(TARGET).tex

# Generate QCM figures from Python scripts
.PHONY: qcm-figures
qcm-figures:
	@echo "Generating QCM figures from Python scripts..."
	cd qcm/figures && python3 generate_temp_plots.py
	cd qcm/figures && python3 generate_showtempair.py
	cd qcm/figures && python3 generate_showtempwater.py
	@echo "QCM figures generated successfully."

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
