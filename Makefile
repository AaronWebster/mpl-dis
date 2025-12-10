TARGET=mpl-dis

# Docker image to use (same as release workflow)
DOCKER_IMAGE=texlive/texlive:latest
DOCKER_RUN=docker run --rm -v "$(PWD):/workdir" -w /workdir

# Check if Docker is available
DOCKER_AVAILABLE := $(shell command -v docker 2> /dev/null)

.PHONY: all

all: $(TARGET).pdf

# Display help information about available targets
.PHONY: help
help:
	@echo "Available targets:"
	@echo ""
	@echo "Local targets (require tools installed):"
	@echo "  make lint           - Lint all LaTeX files with chktex"
	@echo "  make format         - Format all LaTeX files with latexindent"
	@echo "  make check-format   - Check if files need formatting (dry-run)"
	@echo "  make check          - Run lint and check-format"
	@echo "  make lint-format    - Format then lint all files"
	@echo ""
	@echo "Docker targets (use texlive/texlive:latest image):"
	@echo "  make docker-pull         - Pull the Docker image"
	@echo "  make docker-build        - Build PDF in Docker"
	@echo "  make docker-lint         - Lint files in Docker"
	@echo "  make docker-format       - Format files in Docker"
	@echo "  make docker-check-format - Check formatting in Docker"
	@echo "  make docker-check        - Run comprehensive checks in Docker"
	@echo ""
	@echo "Other targets:"
	@echo "  make all     - Build the PDF (default)"
	@echo "  make clean   - Remove build artifacts"
	@echo "  make spell   - Spell check with hunspell"

single:
	pdflatex -interaction=nonstopmode -halt-on-error -shell-escape $(TARGET).tex

spell:
	hunspell -l -t -i utf-8 $(TARGET).tex

# Lint LaTeX source files using chktex
.PHONY: lint
lint:
	@echo "Linting LaTeX files with chktex..."
	@find . -name "*.tex" -type f ! -path "./external/*" ! -path "./.git/*" -exec chktex {} \;
	@echo "Linting complete."

# Format LaTeX source files using latexindent
.PHONY: format
format:
	@echo "Formatting LaTeX files with latexindent..."
	@find . -name "*.tex" -type f ! -path "./external/*" ! -path "./.git/*" -exec latexindent -l .latexindent.yaml -w -s {} \;
	@find . -name "*.bak*" -type f -delete
	@echo "Formatting complete."

# Lint and format all LaTeX source files
.PHONY: lint-format
lint-format: format lint

# Check formatting without applying changes (dry-run)
.PHONY: check-format
check-format:
	@echo "Checking LaTeX file formatting (dry-run)..."
	@FILES_TO_FORMAT=0; \
	for file in $$(find . -name "*.tex" -type f ! -path "./external/*" ! -path "./.git/*"); do \
		if ! latexindent -l .latexindent.yaml -s "$$file" -o=/tmp/latexindent_check.tex 2>/dev/null; then \
			echo "Error checking $$file"; \
			continue; \
		fi; \
		if ! diff -q "$$file" /tmp/latexindent_check.tex >/dev/null 2>&1; then \
			echo "Would reformat: $$file"; \
			FILES_TO_FORMAT=$$((FILES_TO_FORMAT + 1)); \
		fi; \
	done; \
	rm -f /tmp/latexindent_check.tex; \
	if [ $$FILES_TO_FORMAT -eq 0 ]; then \
		echo "All files are properly formatted!"; \
	else \
		echo "$$FILES_TO_FORMAT file(s) need formatting. Run 'make format' to fix."; \
		exit 1; \
	fi

# Comprehensive offline check: lint + check formatting
.PHONY: check
check: check-format lint
	@echo "All checks passed!"

# Docker-based targets (use same image as release workflow)

# Pull the Docker image
.PHONY: docker-pull
docker-pull:
ifdef DOCKER_AVAILABLE
	@echo "Pulling Docker image: $(DOCKER_IMAGE)..."
	docker pull $(DOCKER_IMAGE)
else
	@echo "Error: Docker is not available. Please install Docker first."
	@exit 1
endif

# Install linting/formatting tools in Docker container
.PHONY: docker-setup
docker-setup: docker-pull
	@echo "Setting up linting and formatting tools in Docker..."
	$(DOCKER_RUN) $(DOCKER_IMAGE) sh -c "\
		apt-get update -qq && \
		apt-get install -y chktex texlive-extra-utils python3-pip && \
		pip3 install -r requirements.txt --break-system-packages"

# Build PDF using Docker
.PHONY: docker-build
docker-build:
ifdef DOCKER_AVAILABLE
	@echo "Building PDF in Docker container..."
	$(DOCKER_RUN) $(DOCKER_IMAGE) sh -c "\
		apt-get update -qq && \
		apt-get install -y python3-pip git && \
		pip3 install -r requirements.txt --break-system-packages && \
		make"
else
	@echo "Error: Docker is not available. Please install Docker first."
	@exit 1
endif

# Lint using Docker
.PHONY: docker-lint
docker-lint:
ifdef DOCKER_AVAILABLE
	@echo "Linting LaTeX files in Docker container..."
	$(DOCKER_RUN) $(DOCKER_IMAGE) sh -c "\
		apt-get update -qq && \
		apt-get install -y chktex && \
		make lint"
else
	@echo "Error: Docker is not available. Please install Docker first."
	@exit 1
endif

# Format using Docker
.PHONY: docker-format
docker-format:
ifdef DOCKER_AVAILABLE
	@echo "Formatting LaTeX files in Docker container..."
	$(DOCKER_RUN) $(DOCKER_IMAGE) sh -c "\
		apt-get update -qq && \
		apt-get install -y texlive-extra-utils && \
		make format"
else
	@echo "Error: Docker is not available. Please install Docker first."
	@exit 1
endif

# Check formatting using Docker
.PHONY: docker-check-format
docker-check-format:
ifdef DOCKER_AVAILABLE
	@echo "Checking formatting in Docker container..."
	$(DOCKER_RUN) $(DOCKER_IMAGE) sh -c "\
		apt-get update -qq && \
		apt-get install -y texlive-extra-utils && \
		make check-format"
else
	@echo "Error: Docker is not available. Please install Docker first."
	@exit 1
endif

# Comprehensive check using Docker
.PHONY: docker-check
docker-check:
ifdef DOCKER_AVAILABLE
	@echo "Running comprehensive checks in Docker container..."
	$(DOCKER_RUN) $(DOCKER_IMAGE) sh -c "\
		apt-get update -qq && \
		apt-get install -y chktex texlive-extra-utils && \
		make check"
else
	@echo "Error: Docker is not available. Please install Docker first."
	@exit 1
endif

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
