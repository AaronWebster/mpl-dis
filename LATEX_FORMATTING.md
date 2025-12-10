# LaTeX Linting and Formatting

This repository uses modern LaTeX linting and formatting tools to ensure consistent code quality and readability.

## Tools

### ChkTeX
ChkTeX is a LaTeX linter that checks for common errors and stylistic issues in LaTeX documents.

- Configuration file: `.chktexrc`
- Checks for: spacing issues, quotation marks, ellipsis usage, and more

### latexindent
latexindent is a Perl script that formats LaTeX source code with consistent indentation and structure.

- Configuration file: `.latexindent.yaml`
- Features: consistent 2-space indentation, aligned environments, trailing whitespace removal

## Usage

### Linting
To check all LaTeX files for issues:
```bash
make lint
```

### Formatting
To automatically format all LaTeX source files:
```bash
make format
```

### Combined
To format and then lint all files:
```bash
make lint-format
```

## Installation

If you need to install the tools manually:

```bash
# On Ubuntu/Debian
sudo apt-get install chktex texlive-extra-utils

# On macOS with Homebrew
brew install chktex
# latexindent is included with MacTeX
```

## Configuration Details

### .chktexrc
The ChkTeX configuration file enables warnings for best practices while disabling overly pedantic checks that don't apply to academic writing.

### .latexindent.yaml
The latexindent configuration ensures:
- Consistent 2-space indentation
- Aligned math environments
- Proper line breaks around environments
- Removal of trailing whitespace
- Preservation of logical blank lines

## Notes

- Backup files (*.bak*) are automatically created during formatting and cleaned up
- The tools skip the `external/` and `.git/` directories
- Formatting is applied consistently across all 269+ .tex files in the repository
