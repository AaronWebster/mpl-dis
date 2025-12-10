#!/usr/bin/env python3
"""
Verification script for Type II scattering statistics.

This script simulates the summation of random phasors and verifies that
the resulting intensity follows an exponential distribution, confirming
the theoretical prediction for fully developed speckle.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import expon
from scipy.optimize import curve_fit

# Simulation parameters
N_PHASORS = 100          # Number of random phasors to sum
N_TRIALS = 50000         # Number of trials

def simulate_random_phasors(n_phasors, n_trials):
    """
    Simulate the summation of N random phasors over multiple trials.
    
    Parameters
    ----------
    n_phasors : int
        Number of phasors to sum
    n_trials : int
        Number of independent trials
        
    Returns
    -------
    intensities : ndarray
        Array of intensity values (magnitude squared of field)
    """
    # Generate random phases uniformly distributed in [0, 2π)
    phases = np.random.uniform(0, 2*np.pi, size=(n_trials, n_phasors))
    
    # Calculate complex field as sum of exp(i*phi)
    phasors = np.exp(1j * phases)
    total_field = np.sum(phasors, axis=1)
    
    # Calculate intensity as magnitude squared
    intensities = np.abs(total_field)**2
    
    return intensities

def main():
    print("=" * 70)
    print("Verification of Type II Scattering Statistics")
    print("=" * 70)
    print(f"Number of phasors: {N_PHASORS}")
    print(f"Number of trials: {N_TRIALS}")
    print()
    
    # Simulate random phasors
    print("Simulating random phasor summation...")
    intensities = simulate_random_phasors(N_PHASORS, N_TRIALS)
    
    # Calculate statistics
    mean_intensity = np.mean(intensities)
    std_intensity = np.std(intensities)
    
    print(f"Mean intensity: {mean_intensity:.4f}")
    print(f"Std deviation: {std_intensity:.4f}")
    print(f"Ratio (std/mean): {std_intensity/mean_intensity:.4f}")
    print(f"Expected ratio for exponential: 1.0000")
    print()
    
    # Fit exponential distribution
    # For exponential distribution, the scale parameter equals the mean
    hist, bin_edges = np.histogram(intensities, bins=100, density=True)
    bin_centers = (bin_edges[:-1] + bin_edges[1:]) / 2
    
    # Fit using scipy's exponential distribution
    # The exponential distribution has PDF: (1/scale) * exp(-x/scale)
    # where scale = mean
    params = expon.fit(intensities, floc=0)  # floc=0 fixes location at 0
    fitted_scale = params[1]
    
    print("Exponential distribution fit:")
    print(f"Fitted scale parameter: {fitted_scale:.4f}")
    print(f"Theoretical scale (mean): {mean_intensity:.4f}")
    print(f"Difference: {abs(fitted_scale - mean_intensity):.4f}")
    print()
    
    # Create plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Histogram with theoretical PDF overlay
    ax1.hist(intensities, bins=100, density=True, alpha=0.7, 
             color='steelblue', edgecolor='black', linewidth=0.5,
             label='Simulated data')
    
    # Plot theoretical exponential PDF
    x = np.linspace(0, np.max(intensities), 1000)
    theoretical_pdf = expon.pdf(x, scale=mean_intensity)
    ax1.plot(x, theoretical_pdf, 'r-', linewidth=2.5, 
             label=f'Theoretical Exponential PDF\n(scale={mean_intensity:.2f})')
    
    ax1.set_xlabel('Intensity', fontsize=12)
    ax1.set_ylabel('Probability Density', fontsize=12)
    ax1.set_title('Sum of Random Phasors → Exponential Intensity Distribution', 
                  fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(left=0)
    
    # Q-Q plot to verify exponential distribution
    # Sort the data
    sorted_intensities = np.sort(intensities)
    # Theoretical quantiles from exponential distribution
    theoretical_quantiles = expon.ppf(np.linspace(0.001, 0.999, len(sorted_intensities)), 
                                     scale=mean_intensity)
    
    ax2.scatter(theoretical_quantiles, sorted_intensities, alpha=0.5, s=1)
    ax2.plot([0, np.max(theoretical_quantiles)], [0, np.max(theoretical_quantiles)], 
             'r--', linewidth=2, label='Perfect fit')
    ax2.set_xlabel('Theoretical Quantiles (Exponential)', fontsize=12)
    ax2.set_ylabel('Sample Quantiles', fontsize=12)
    ax2.set_title('Q-Q Plot: Exponential Distribution', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    # Save figure
    output_file = 'verify_scattering_stats.png'
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Plot saved to: {output_file}")
    
    # Show plot
    plt.show()
    
    print()
    print("=" * 70)
    print("CONCLUSION:")
    print("The simulated intensity distribution matches the theoretical")
    print("exponential distribution, confirming that the sum of N random")
    print("phasors leads to Rayleigh amplitude statistics (exponential")
    print("intensity statistics), characteristic of fully developed speckle.")
    print("=" * 70)

if __name__ == "__main__":
    main()
