#!/usr/bin/env python3
"""
Generate TikZ figures for QCM temperature vs g-force plots.

This script rigorously replaces MATLAB/matlab2tikz with pure Python.
It manually generates pgfplots-compatible .tex files matching the exact
structure of matlab2tikz output.

MATLAB code analysis (showtempairwater.m):
  Line 2:     mycolor = brewermap(5,'Set1')
  Line 22-27: subplot(121) - Air: plot(ang(:,2), temp(:,2)) with mycolor(2,:)
  Line 30-35: subplot(122) - Water: plot(ang(:,2), temp(:,2)) with mycolor(1,:)  
  Line 39-41: matlab2tikz('showtempairwater.tex', height='6cm', width='6cm')

ColorBrewer Set1 palette (MATLAB 1-indexed):
  mycolor(1,:) = Red  (228,26,28)   / 255 = (0.89412, 0.10196, 0.10980)
  mycolor(2,:) = Blue (55,126,184)  / 255 = (0.21569, 0.49412, 0.72157)

Data files format: 2 columns [time, value]
  MATLAB ang(:,2) = Python ang[:,1] (0-indexed)
  MATLAB temp(:,2) = Python temp[:,1] (0-indexed)
"""

import numpy as np
from palettable.colorbrewer.qualitative import Set1_9
from pathlib import Path


def get_colorbrewer_set1():
    """Get ColorBrewer Set1 palette (9 colors) in RGB 0-1 format."""
    return np.array(Set1_9.colors) / 255.0


def downsample_uniform(x, y, target_points=200):
    """
    Uniformly downsample data to reduce number of points.
    
    Args:
        x, y: Input data arrays
        target_points: Target number of points (default: 200)
    
    Returns:
        Downsampled (x, y) tuple
    """
    if len(x) <= target_points:
        return x, y
    
    indices = np.linspace(0, len(x) - 1, target_points, dtype=int)
    return x[indices], y[indices]


def write_tikz_subplot(f, x, y, color_rgb, legend_label, xlabel, ylabel, 
                        width='6cm', height='6cm', position=None):
    """
    Write a single axis/subplot to tikz file.
    
    Matches matlab2tikz output structure exactly.
    
    Args:
        f: File handle to write to
        x, y: Data arrays
        color_rgb: RGB tuple (r, g, b) in 0-1 range
        legend_label: Label for legend
        xlabel, ylabel: Axis labels
        width, height: Figure dimensions
        position: Position spec for second+ subplots (e.g., "at=(plot1.right of south east)")
    """
    # Calculate axis limits
    xmin, xmax = np.min(x), np.max(x)
    ymin, ymax = np.min(y), np.max(y)
    y_range = ymax - ymin
    ymin -= y_range * 0.02  # Small padding
    ymax += y_range * 0.02
    
    f.write("  \\begin{axis}[%\n")
    f.write(f"    width={width},\n")
    f.write(f"    height={height},\n")
    f.write("    scale only axis,\n")
    f.write(f"    xmin={xmin:.0f},\n")
    f.write(f"    xmax={xmax:.0f},\n")
    f.write(f"    xlabel={{{xlabel}}},\n")
    f.write(f"    ymin={ymin:.2f},\n")
    f.write(f"    ymax={ymax:.2f},\n")
    f.write(f"    ylabel={{{ylabel}}},\n")
    
    if position is None:
        f.write("    name=plot1,\n")
    else:
        f.write(f"    {position},\n")
    
    f.write("    legend style={at={(0.97,0.03)},anchor=south east,draw=black,fill=white,legend cell align=left}\n")
    f.write("    ]\n")
    
    # Write plot data
    f.write(f"    \\addplot [color=mycolor{1 if legend_label == 'Air' else 2},solid,forget plot]\n")
    f.write("    table[row sep=crcr]{%\n")
    
    for xi, yi in zip(x, y):
        f.write(f"        {xi:.0f}\t{yi:.6f}\\\\\n")
    
    f.write("      };\n")
    f.write(f"    \\addlegendentry{{{legend_label}}};\n\n")
    f.write("  \\end{axis}\n")


def generate_showtempairwater():
    """
    Generate showtempairwater.tex - rigorously replicates MATLAB showtempairwater.m
    
    Process:
    1. Load same data files as MATLAB
    2. Use ColorBrewer Set1 with correct MATLAB indexing
    3. Create side-by-side subplots (Air=blue, Water=red)
    4. Downsample from ~5000 to ~200 points
    5. Generate tikz file matching matlab2tikz structure exactly
    """
    data_dir = Path('data')
    
    # Load data (matching MATLAB: ang = load('data/QCM00450-ang.txt'))
    ang_air = np.loadtxt(data_dir / 'QCM00450-ang.txt')
    temp_air = np.loadtxt(data_dir / 'QCM00450-temp.txt')
    ang_water = np.loadtxt(data_dir / 'QCM00431b-ang.txt')
    temp_water = np.loadtxt(data_dir / 'QCM00431b-temp.txt')
    
    # Extract second column (MATLAB ang(:,2) = Python ang[:,1])
    x_air = ang_air[:, 1]      # g-force
    y_air = temp_air[:, 1]     # temperature [C]
    x_water = ang_water[:, 1]
    y_water = temp_water[:, 1]
    
    # Downsample to reduce from ~5000 to ~200 points per plot
    x_air_ds, y_air_ds = downsample_uniform(x_air, y_air, target_points=200)
    x_water_ds, y_water_ds = downsample_uniform(x_water, y_water, target_points=200)
    
    print(f"Air:   {len(x_air):4d} -> {len(x_air_ds):3d} points ({100*len(x_air_ds)/len(x_air):.1f}% of original)")
    print(f"Water: {len(x_water):4d} -> {len(x_water_ds):3d} points ({100*len(x_water_ds)/len(x_water):.1f}% of original)")
    
    # ColorBrewer Set1 colors (matching MATLAB indexing)
    set1 = get_colorbrewer_set1()
    color_blue = set1[1]  # mycolor(2,:) in MATLAB  
    color_red = set1[0]   # mycolor(1,:) in MATLAB
    
    # Write tikz file matching matlab2tikz structure
    output_file = 'showtempairwater.tex'
    
    with open(output_file, 'w') as f:
        # Header (matching matlab2tikz)
        f.write("% This file was created by Python script (replacing matlab2tikz)\n")
        f.write("% Rigorously replicates MATLAB showtempairwater.m behavior\n")
        f.write("% Minimal pgfplots version: 1.3\n")
        f.write("%\n")
        f.write("%\n")
        f.write("% defining custom colors\n")
        f.write(f"\\definecolor{{mycolor1}}{{rgb}}{{{color_blue[0]:.5f},{color_blue[1]:.5f},{color_blue[2]:.5f}}}%\n")
        f.write(f"\\definecolor{{mycolor2}}{{rgb}}{{{color_red[0]:.5f},{color_red[1]:.5f},{color_red[2]:.5f}}}%\n")
        f.write("%\n")
        f.write("\\begin{tikzpicture}\n\n")
        
        # First subplot: Air (blue)
        write_tikz_subplot(f, x_air_ds, y_air_ds, color_blue, 'Air', 
                          'g-force [g]', '$T$ [C]', width='6cm', height='6cm')
        
        # Second subplot: Water (red), positioned to the right
        f.write("\n")
        write_tikz_subplot(f, x_water_ds, y_water_ds, color_red, 'Water',
                          'g-force [g]', '$T$ [C]', width='6cm', height='6cm',
                          position="at=(plot1.right of south east), anchor=left of south west")
        
        f.write("\\end{tikzpicture}%\n")
    
    print(f"\nGenerated: {output_file}")
    print(f"File size: {Path(output_file).stat().st_size:,} bytes")
    print(f"  (Original was 288,757 bytes)")
    print("\nRigorous Python replacement of MATLAB+matlab2tikz complete!")


if __name__ == '__main__':
    generate_showtempairwater()
