TARGET=mpl-dis
DOCKER_IMAGE=texlive/texlive:latest
TEX_FILES=$(shell git ls-files '*.tex')
LINT_TEX_FILES=$(shell git ls-files '*.tex' ':!:sandbox/**' ':!:wlgr/**' ':!:qcm/unsorted/**' ':!:backmatter/fresnel/allthreelayerfresnel.tex' ':!:**/colorpreview.tex')
DOCKER_RUN=docker run --rm -v $(PWD):/work -w /work $(DOCKER_IMAGE)

.PHONY: all lint format check-format check docker-pull docker-lint docker-format docker-check docker-build help

all: $(TARGET).pdf

single:
	pdflatex -interaction=nonstopmode -halt-on-error -shell-escape $(TARGET).tex

spell:
	hunspell -l -t -i utf-8 $(TARGET).tex

$(TARGET).pdf: $(TARGET).tex $(shell find . -type f -name "*.tex") qcm-figures
	mkdir -p external
	git rev-parse HEAD > commithash.tex
	latexmk -f -pdf -use-make $(TARGET).tex || \
		(test -f $(TARGET).pdf && \
		echo "PDF generated successfully despite warnings" && \
		exit 0)

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

lint:
	chktex -q $(LINT_TEX_FILES)

format:
	latexindent -w -s -g=/dev/null $(TEX_FILES)

check-format:
	latexindent -s -g=/dev/null $(TEX_FILES) >/dev/null

check: lint check-format

docker-pull:
	docker pull $(DOCKER_IMAGE)

docker-lint:
	$(DOCKER_RUN) sh -c "chktex -q $(LINT_TEX_FILES)"

docker-format:
	$(DOCKER_RUN) sh -c "latexindent -w -s -g=/dev/null $(TEX_FILES)"

docker-check:
	$(DOCKER_RUN) sh -c "chktex -q $(LINT_TEX_FILES) && latexindent -s -g=/dev/null $(TEX_FILES) >/dev/null"

docker-build:
	$(DOCKER_RUN) sh -c "apt-get update -qq && apt-get install -y git python3-pip && pip3 install -r requirements.txt --break-system-packages && make all"

help:
	@echo "Available targets:"
	@echo "  all            - Build $(TARGET).pdf"
	@echo "  lint           - Run chktex on all tracked .tex files"
	@echo "  format         - Run latexindent on all tracked .tex files (in-place)"
	@echo "  check-format   - Dry-run latexindent to ensure clean formatting"
	@echo "  check          - Run lint and formatting checks"
	@echo "  qcm-figures    - Generate QCM figures"
	@echo "  clean          - Remove build artifacts"
	@echo "  docker-pull    - Pull $(DOCKER_IMAGE)"
	@echo "  docker-lint    - Run chktex inside Docker"
	@echo "  docker-format  - Run latexindent inside Docker"
	@echo "  docker-check   - Run lint and format checks inside Docker"
	@echo "  docker-build   - Build PDF inside Docker (matches release workflow)"
