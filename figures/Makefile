# makes all the figures

NUMJOBS=${NUMJOBS:-" -j4 "}

.PHONY: all clean

all: qcm_annotated_picture.pdf_tex

# svg figures which should be latex'd
%.pdf_tex: %.svg
	inkscape --export-pdf=$(@:.pdf_tex=.pdf) --export-latex $<
