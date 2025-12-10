# LaTeX linting and formatting

This repository standardises LaTeX linting and formatting with two tools:

- **ChkTeX** for linting.
- **latexindent** for formatting (2-space indentation, preamble included).

Configuration lives in:

- `.chktexrc`
- `.latexindent.yaml`

## Local workflow

```bash
make lint          # run chktex on all tracked .tex files
make format        # apply latexindent in-place
make check-format  # dry-run latexindent to ensure files are clean
make check         # lint + formatting check
```

> Note: linting excludes `sandbox/**`, `wlgr/**`, `qcm/unsorted/**`,
> `backmatter/fresnel/allthreelayerfresnel.tex`, and `**/colorpreview.tex`
> because these rely on generated or legacy auxiliary files not present in the
> repository. Formatting still runs across all tracked `.tex` files.

## Docker workflow (matches the release container)

```bash
make docker-pull    # fetch texlive/texlive:latest
make docker-lint    # run chktex inside the container
make docker-format  # apply latexindent inside the container
make docker-check   # lint + formatting check inside Docker
make docker-build   # full build in Docker (same image as release)
```

All Docker targets mount the repository into the container, so changes are
written to your working tree.
