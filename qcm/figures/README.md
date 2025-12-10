# QCM Figure Generation

This directory contains Python scripts for generating TikZ/pgfplots figures from QCM experimental data.

## Overview

The figure generation has been converted from MATLAB/matlab2tikz to pure Python using numpy and palettable. This provides several benefits:

- **Smaller output files**: Generated .tex files are 90-96% smaller
- **Faster generation**: No need to start MATLAB
- **Reproducible**: Exact dependencies specified in requirements.txt
- **Open source**: No proprietary software required

## Requirements

Install dependencies with:

```bash
pip install -r ../../requirements.txt
```

Required packages:
- numpy >= 1.20.0
- palettable >= 3.3.0

## Scripts

### generate_temp_plots.py
Generates `showtempairwater.tex` - side-by-side comparison of temperature vs g-force for air and water datasets.

**Data files used:**
- `data/QCM00450-ang.txt` (Air)
- `data/QCM00450-temp.txt` (Air)
- `data/QCM00431b-ang.txt` (Water)
- `data/QCM00431b-temp.txt` (Water)

**Output:** 
- File: `showtempairwater.tex`
- Size: ~10KB (was 288KB from MATLAB)
- Downsamples from ~5000 to ~200 points per subplot

### generate_showtempair.py
Generates `showtempair.tex` - 4 stacked subplots showing Δf, ΔΓ, temperature, and g-force vs time.

**Data files used:**
- `data/QCM00431b-freq.txt`
- `data/QCM00431b-res.txt`
- `data/QCM00431b-temp.txt`
- `data/QCM00431b-ang.txt`

**Output:**
- File: `showtempair.tex`
- Size: ~59KB (was 626KB from MATLAB)
- Downsamples from ~5000 to ~500 points per subplot

### generate_showtempwater.py
Generates `showtempwater.tex` - 4 stacked subplots for water dataset.

**Data files used:**
- `data/QCM00450-freq.txt`
- `data/QCM00450-res.txt`
- `data/QCM00450-temp.txt`
- `data/QCM00450-ang.txt`

**Output:**
- File: `showtempwater.tex`
- Size: ~59KB
- Downsamples from ~5000 to ~500 points per subplot

## Usage

Generate all figures:

```bash
make qcm-figures
```

Or individually:

```bash
cd qcm/figures
python3 generate_temp_plots.py
python3 generate_showtempair.py
python3 generate_showtempwater.py
```

## Technical Details

### ColorBrewer Palettes

All scripts use the ColorBrewer Set1 qualitative color palette, matching the original MATLAB implementation:

- Color 1 (Red): RGB(0.894, 0.102, 0.110)
- Color 2 (Blue): RGB(0.216, 0.494, 0.722)
- Color 3 (Green): RGB(0.302, 0.686, 0.290)
- Color 4 (Purple): RGB(0.596, 0.306, 0.639)

### Downsampling

To reduce file sizes while maintaining visual quality, data is uniformly downsampled:
- Air/Water comparison plots: ~5000 → 200 points per plot (4% of original)
- Time series plots: ~5000 → 500 points per subplot (10% of original)

This dramatically reduces the .tex file size without visible loss of detail.

### Output Format

Generated .tex files are pgfplots-compatible and can be included in LaTeX documents using:

```latex
\import{qcm/figures/}{showtempairwater}
```

The files are marked as build artifacts in `.gitignore` and regenerated during each build.

## Migration Notes

**Original MATLAB scripts (removed):**
- `showtempair.m`
- `showtempwater.m`
- `showtempairwater.m`

**Dependencies removed:**
- MATLAB
- matlab2tikz library
- brewermap.m

**Size comparison:**
| File | MATLAB output | Python output | Reduction |
|------|---------------|---------------|-----------|
| showtempair.tex | 626 KB | 59 KB | 91% |
| showtempairwater.tex | 288 KB | 10 KB | 96% |
| showtempwater.tex | ~600 KB | 59 KB | 90% |

## References

- ColorBrewer color schemes: http://colorbrewer.org/
- Palettable documentation: https://jiffyclub.github.io/palettable/
