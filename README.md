# Visual Discomfort Analysis using Fourier Spectrum Metrics

This project investigates the relationship between the spatial distribution of Fourier energy in images and the subjective perception of visual discomfort. Inspired by Olivier Penacchio's "A mechanistic account of visual discomfort" and A. Parraga et al.'s "Aesthetics without semantics" (upcoming), the goal is to quantify deviations from natural image statistics using Fourier-based metrics and analyze their correlation with discomfort ratings.

## 1. Project Overview

Visual discomfort is a perceptual response often caused by specific statistical structures in images, such as the patterns found in Op-Art. This project aims to:

- Develop a metric (SumWeightedAmplitudeDistance) to quantify deviations in the 2D Fourier spectrum of images.
- Compare this metric with Olivier Penacchio's residuals to assess whether they capture different statistical properties.
- Evaluate the correlation between these metrics and visual discomfort across multiple datasets.

## 2. Methodology

### 2.1 Metric Calculation

For each image in the dataset, we:

1. **Preprocess the image:**

   - Apply a personalized Hann window.
   - Convert to grayscale.
   - Resize to 256x256 pixels.

2. **Fourier Transform:**

   - Compute the 2D FFT of the processed image.

3. **Peak Detection:**

   - Identify prominent spectral peaks based on three parameters:
     - **Prominence:** Minimum required amplitude difference between the peak and its local neighborhood.
     - **Window Size:** Defines the local neighborhood for amplitude calculation.
     - **Threshold Radius:** Attenuates peaks near the DC component.

4. **SumWeightedAmplitudeDistance Metric:**

   - For each detected peak:

![image](https://github.com/user-attachments/assets/0c33567f-b163-440f-ba09-9ab1c9c9c32e)


Where:

- **Amplitude**: FFT amplitude at the peak.
- **Distance**: Euclidean distance from the peak to the DC component.
- **Weight**: Attenuation factor for peaks near the center (0 to 1).

### 2.2 Visual Validation

A custom visualization tool overlays detected peaks on the Fourier spectrum to verify detection quality (`visualize_fourier_and_peaks.m`).

![image](https://github.com/user-attachments/assets/0c83dfd9-77d3-484e-af64-1f99d81871c2)

### 2.3 Correlation Analysis

We compute Pearson and Spearman correlations between:

- **Metrics**: SumWeightedAmplitudeDistance
- **Subjective Ratings**: Discomfort or aesthetic scores

## 3. Datasets

1. **Buildings Dataset:**

   - 148 architectural images (combined from buildings0 and buildings1 datasets).
   - Rated by 10 subjects on a discomfort scale (1 to 7).

2. **MSC (Minimum Semantic Content) Dataset:**

   - 10,426 images of natural and modified landscapes.
   - Rated on an aesthetic scale (0 to 5).

3. **Art Datasets:**

   - 50 images each (Xortia and Becca datasets).
   - Abstract and artistic images rated for discomfort (1 to 7).

## 4. Results

| Dataset      | Residuals (r)          | SumWeightedAmplitudeDistance (r) |
| ------------ | ---------------------- | -------------------------------- |
| MSC          | -0.0571 (p = 0.0017)   | -0.0864 (p = 2.004e-06)          |
| Buildings    | 0.6208 (p = 3.857e-17) | 0.5988 (p = 2.288e-13)           |
| Becca (Art)  | 0.5556 (p = 2.806e-05) | 0.5003 (p = 0.0002)              |
| Xortia (Art) | 0.5012 (p = 0.0002)    | 0.3377 (p = 0.0165)              |

- **Building Dataset**: Both metrics show significant positive correlations with discomfort.
- **MSC Dataset**: Weak but significant negative correlation for both metrics.
- **Art Datasets**: Moderate correlation for both metrics, suggesting statistical anomalies in artistic patterns.

## 5. Repository Structure

```
.
├── datasets/                  % Raw image datasets (e.g., buildings, MSC, art datasets)
├── FilteredImages/            % (Can be ignored) Preprocessed images indexes for the msc Dataset.
├── metricsComparison/         % Scripts comparing different metrics (SumWeightedAmplitudeDistance vs Residuals)
├── OlivierResidue/            % Contains code and data related to Penacchio's residual calculation
├── PeaksMetric/               % SumWeightedAmplitudeDistance metric computation scripts
├── ratings/                   % Subjective ratings for discomfort and aesthetics
├── Residuals/                 % Precomputed residuals (Olivier's method) for various datasets
├── ResultsTables/             % Final computed metrics and combined tables for analysis
└── README.md                  % Project documentation
```

## 6. How to Reproduce the Analysis

### Prerequisites

- MATLAB (R2022b or newer recommended)
- Image Processing Toolbox (24.2)
- Signal Processing Toolbox (24.2)
- Statistics and Machine Learning Toolbox (24.2)

### Steps

1. Clone the repository:

   ```bash
   git clone https://github.com/your-repo/visual-discomfort-analysis.git
   cd visual-discomfort-analysis
   ```

2. Ensure datasets are available in the `ratings/` and `ResultsTables/` directories.

3. Run the main analysis scripts in PeaksMetric Folder or Olivier Residue:

   ```matlab
   % To Analyze peaks:
      Open MATLAB and navigate to the PeaksMetric folder
      Open script "distpeaks_main.m"
      Fill the parameters in the bottom section.
      Run the main script "distpeaks_main.m"

   %To Analyze residuals: Residuals
      Navigate to the OlivierMetric
      Open scripts "main_discomfort.m"
      Fill the parameters
      Run the main script
      
   % Cluster and visualize building discomfort levels
      run('scripts/buildings_cluster_analysis.m')
   ```

## 7. Conclusions

- **Metric Performance**: The SumWeightedAmplitudeDistance metric captures statistical anomalies in the Fourier spectrum and correlates with visual discomfort across diverse datasets.
- **Complementary Insights**: While Olivier's residuals capture general deviations, our metric highlights peak-specific anomalies, providing complementary information.
- **Future Work**: Extending the analysis to other perceptual effects (e.g., visual tension) and improving peak detection for enhanced robustness.

## 8. Contributors

- **Aiman** - Project lead and implementation
- **Mentorship** - A. Parraga (Computer Vision Center, UAB)

## 9. References

- Penacchio, O., & Wilkins, A. J. (2015). A mechanistic account of visual discomfort. *Proceedings of the Royal Society B: Biological Sciences.*
- Parraga, C. A., et al. (Upcoming). "Aesthetics without semantics."

## 10. License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

