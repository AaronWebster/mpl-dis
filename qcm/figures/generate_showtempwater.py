#!/usr/bin/env python3
"""
Generate TikZ figure for QCM measurements vs time (4 subplots) - Water dataset.

This script rigorously replaces MATLAB/matlab2tikz with pure Python.
It manually generates pgfplots-compatible .tex files matching the exact
structure of matlab2tikz output.

MATLAB code analysis (showtempwater.m):
  Line 3:     mycolor = brewermap(5,'Set1')
  Line 7-12:  subplot(411) - Δf: plot(tmp(:,1)-tmp(1,1), tmp(:,2)) with mycolor(2,:)
  Line 14-19: subplot(412) - ΔΓ: plot(tmp(:,1)-tmp(1,1), tmp(:,2)) with mycolor(1,:)
  Line 21-25: subplot(413) - T: plot(tmp(:,1)-tmp(1,1), tmp(:,2)) with mycolor(3,:)
  Line 28-33: subplot(414) - g-force: plot(tmp(:,1)-tmp(1,1), tmp(:,2)) with mycolor(4,:)
  Line 42-45: matlab2tikz('showtempwater.tex', height='2.5cm', width='12cm')
  Uses QCM00450 dataset (water)

ColorBrewer Set1 palette (MATLAB 1-indexed):
  mycolor(1,:) = Red    (228,26,28)   / 255 = (0.89412, 0.10196, 0.10980)
  mycolor(2,:) = Blue   (55,126,184)  / 255 = (0.21569, 0.49412, 0.72157)
  mycolor(3,:) = Green  (77,175,74)   / 255 = (0.30196, 0.68627, 0.29020)
  mycolor(4,:) = Purple (152,78,163)  / 255 = (0.59608, 0.30588, 0.63922)

Data files format: 2 columns [time, value]
  MATLAB tmp(:,1)-tmp(1,1) = Python tmp[:,0] - tmp[0,0] (time relative to start)
  MATLAB tmp(:,2) = Python tmp[:,1] (measurement value)
"""

import numpy as np
from palettable.colorbrewer.qualitative import Set1_9
from pathlib import Path


def get_colorbrewer_set1():
    """Get ColorBrewer Set1 palette (9 colors) in RGB 0-1 format."""
    return np.array(Set1_9.colors) / 255.0


def downsample_uniform(x, y, target_points=250):
    """
    Uniformly downsample data to reduce number of points.
    
    Args:
        x, y: Input data arrays
        target_points: Target number of points (default: 250)
    
    Returns:
        Downsampled (x, y) tuple
    """
    if len(x) <= target_points:
        return x, y
    
    indices = np.linspace(0, len(x) - 1, target_points, dtype=int)
    return x[indices], y[indices]


def write_tikz_subplot(f, x, y, color_rgb, legend_label, xlabel, ylabel, 
                        ymin, ymax, width='12cm', height='2.5cm', 
                        position=None, first=False, last=False):
    """
    Write a single axis/subplot to tikz file.
    
    Matches matlab2tikz output structure exactly.
    
    Args:
        f: File handle to write to
        x, y: Data arrays
        color_rgb: RGB tuple (r, g, b) in 0-1 range
        legend_label: Label for legend
        xlabel, ylabel: Axis labels
        ymin, ymax: Y-axis limits
        width, height: Figure dimensions
        position: Position spec for second+ subplots
        first: Is this the first subplot?
        last: Is this the last subplot?
    """
    # Calculate axis limits
    xmin_calc, xmax_calc = np.min(x), np.max(x)
    
    f.write("  \\begin{axis}[%\n")
    f.write(f"    width={width},\n")
    f.write(f"    height={height},\n")
    f.write("    scale only axis,\n")
    f.write(f"    xmin={xmin_calc:.2f},\n")
    f.write(f"    xmax={xmax_calc:.2f},\n")
    
    # Only show xlabel on last subplot
    if last:
        f.write(f"    xlabel={{{xlabel}}},\n")
    else:
        f.write("    xticklabel=\\empty,\n")
    
    f.write(f"    ymin={ymin:.4f},\n")
    f.write(f"    ymax={ymax:.4f},\n")
    f.write(f"    ylabel={{{ylabel}}},\n")
    
    if first:
        f.write("    name=plot1,\n")
    else:
        f.write(f"    {position},\n")
    
    f.write("    legend style={at={(0.97,0.97)},anchor=north east,draw=black,fill=white,legend cell align=left}\n")
    f.write("    ]\n")
    
    # Determine color index based on legend label
    color_map = {'$\\Delta\\,f$': 1, '$\\Delta\\Gamma$': 2, '$T$': 3, 'g-force': 4}
    color_idx = color_map.get(legend_label, 1)
    
    # Write plot data
    f.write(f"    \\addplot [color=mycolor{color_idx},solid,forget plot]\n")
    f.write("    table[row sep=crcr]{%\n")
    
    for xi, yi in zip(x, y):
        f.write(f"        {xi:.4f}\t{yi:.6f}\\\\\n")
    
    f.write("      };\n")
    f.write(f"    \\addlegendentry{{{legend_label}}};\n\n")
    f.write("  \\end{axis}\n")


def generate_showtempwater():
    """
    Generate showtempwater.tex - rigorously replicates MATLAB showtempwater.m
    
    Process:
    1. Load same data files as MATLAB (QCM00450 - water dataset)
    2. Use ColorBrewer Set1 with correct MATLAB indexing
    3. Create 4 vertically-stacked subplots
    4. Downsample from ~5000 to ~500 points per subplot
    5. Generate tikz file matching matlab2tikz structure exactly
    """
    data_dir = Path('data')
    
    # Load data (matching MATLAB: tmp = load('data/QCM00450-freq.txt'))
    # Note: showtempwater.m uses QCM00450 dataset (water)
    freq_data = np.loadtxt(data_dir / 'QCM00450-freq.txt')
    res_data = np.loadtxt(data_dir / 'QCM00450-res.txt')
    temp_data = np.loadtxt(data_dir / 'QCM00450-temp.txt')
    ang_data = np.loadtxt(data_dir / 'QCM00450-ang.txt')
    
    # Extract columns and make time relative to start
    # MATLAB: tmp(:,1) - tmp(1,1) and tmp(:,2)
    # Python: tmp[:,0] - tmp[0,0] and tmp[:,1]
    time_freq = freq_data[:, 0] - freq_data[0, 0]
    val_freq = freq_data[:, 1]
    
    time_res = res_data[:, 0] - res_data[0, 0]
    val_res = res_data[:, 1]
    
    time_temp = temp_data[:, 0] - temp_data[0, 0]
    val_temp = temp_data[:, 1]
    
    time_ang = ang_data[:, 0] - ang_data[0, 0]
    val_ang = ang_data[:, 1]
    
    # Downsample to reduce file size (from ~5000 to ~250 points per plot)
    time_freq_ds, val_freq_ds = downsample_uniform(time_freq, val_freq, target_points=250)
    time_res_ds, val_res_ds = downsample_uniform(time_res, val_res, target_points=250)
    time_temp_ds, val_temp_ds = downsample_uniform(time_temp, val_temp, target_points=250)
    time_ang_ds, val_ang_ds = downsample_uniform(time_ang, val_ang, target_points=250)
    
    print(f"Frequency: {len(time_freq):4d} -> {len(time_freq_ds):3d} points")
    print(f"Resistance: {len(time_res):4d} -> {len(time_res_ds):3d} points")
    print(f"Temperature: {len(time_temp):4d} -> {len(time_temp_ds):3d} points")
    print(f"g-force: {len(time_ang):4d} -> {len(time_ang_ds):3d} points")
    
    # ColorBrewer Set1 colors (matching MATLAB indexing)
    set1 = get_colorbrewer_set1()
    color_red = set1[0]     # mycolor(1,:) in MATLAB - for ΔΓ
    color_blue = set1[1]    # mycolor(2,:) in MATLAB - for Δf
    color_green = set1[2]   # mycolor(3,:) in MATLAB - for T
    color_purple = set1[3]  # mycolor(4,:) in MATLAB - for g-force
    
    # Write tikz file matching matlab2tikz structure
    output_file = 'showtempwater.tex'
    
    with open(output_file, 'w') as f:
        # Header (matching matlab2tikz)
        f.write("% This file was created by Python script (replacing matlab2tikz)\n")
        f.write("% Rigorously replicates MATLAB showtempwater.m behavior\n")
        f.write("% Minimal pgfplots version: 1.3\n")
        f.write("%\n")
        f.write("%\n")
        f.write("% defining custom colors\n")
        f.write("% Note: Color indices match MATLAB's 1-based indexing for Set1 palette\n")
        f.write(f"\\definecolor{{mycolor1}}{{rgb}}{{{color_blue[0]:.5f},{color_blue[1]:.5f},{color_blue[2]:.5f}}}%\n")
        f.write(f"\\definecolor{{mycolor2}}{{rgb}}{{{color_red[0]:.5f},{color_red[1]:.5f},{color_red[2]:.5f}}}%\n")
        f.write(f"\\definecolor{{mycolor3}}{{rgb}}{{{color_green[0]:.5f},{color_green[1]:.5f},{color_green[2]:.5f}}}%\n")
        f.write(f"\\definecolor{{mycolor4}}{{rgb}}{{{color_purple[0]:.5f},{color_purple[1]:.5f},{color_purple[2]:.5f}}}%\n")
        f.write("%\n")
        f.write("\\begin{tikzpicture}\n\n")
        
        # Subplot 1: Frequency (blue, mycolor2 in MATLAB)
        write_tikz_subplot(f, time_freq_ds, val_freq_ds, color_blue, '$\\Delta\\,f$',
                          'time [s]', '$\\Delta\\,f$ [Hz]', 
                          ymin=-1.0, ymax=2.0, width='12cm', height='2.5cm',
                          first=True, last=False)
        
        f.write("\n")
        
        # Subplot 2: Resistance (red, mycolor1 in MATLAB)
        write_tikz_subplot(f, time_res_ds, val_res_ds, color_red, '$\\Delta\\Gamma$',
                          'time [s]', '$\\Delta\\Gamma$ [Hz]',
                          ymin=-0.5, ymax=0.5, width='12cm', height='2.5cm',
                          position="at=(plot1.below south west), anchor=above north west",
                          first=False, last=False)
        
        f.write("\n")
        
        # Subplot 3: Temperature (green, mycolor3 in MATLAB)
        write_tikz_subplot(f, time_temp_ds, val_temp_ds, color_green, '$T$',
                          'time [s]', '$T$ [C]',
                          ymin=np.min(val_temp_ds)-0.1, ymax=np.max(val_temp_ds)+0.1, 
                          width='12cm', height='2.5cm',
                          position="at=(plot1.below south west), anchor=above north west, yshift=-2.5cm",
                          first=False, last=False)
        
        f.write("\n")
        
        # Subplot 4: g-force (purple, mycolor4 in MATLAB)
        write_tikz_subplot(f, time_ang_ds, val_ang_ds, color_purple, 'g-force',
                          'time [s]', 'g-force',
                          ymin=np.min(val_ang_ds)-10, ymax=np.max(val_ang_ds)+10,
                          width='12cm', height='2.5cm',
                          position="at=(plot1.below south west), anchor=above north west, yshift=-5.0cm",
                          first=False, last=True)
        
        f.write("\\end{tikzpicture}%\n")
    
    print(f"\nGenerated: {output_file}")
    print(f"File size: {Path(output_file).stat().st_size:,} bytes")
    print("\nRigorous Python replacement of MATLAB+matlab2tikz complete!")


if __name__ == '__main__':
    generate_showtempwater()
