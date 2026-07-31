**🧠AI-Based EEG Signal Processing Pipeline for VR and Non-VR Motor Imagery Analysis**

**📌 Project Overview**

This repository contains the complete MATLAB implementation of an AI-based EEG preprocessing and feature extraction pipeline developed during my research work on **EEG signal analysis for Virtual Reality (VR) and Non-VR motor imagery experiments**.

The pipeline processes raw EEG recordings acquired from a **14-channel Emotiv EPOC X headset**, removes artifacts, extracts frequency-domain and statistical features, and compares EEG characteristics across VR and Non-VR conditions.

**🎯 Objectives**

* Preprocess raw EEG recordings.
* Remove physiological and movement artifacts using ICA.
* Compare EEG recordings collected with and without VR.
* Extract spectral and statistical EEG features.
* Generate publication-quality visualizations.
* Prepare EEG data for machine learning analysis.

 **📂 Repository Structure**

EEG_Actual_VR/
    Raw EEG recordings (VR)

EEG_Actual_noVR/
    Raw EEG recordings (Non-VR)

Results_VR/
    Generated figures and extracted features (VR)

Results_NoVR/
    Generated figures and extracted features (Non-VR)

Scripts/
    MATLAB preprocessing and analysis scripts

Synthetic data pipeline and results/
    Synthetic EEG preprocessing and validation

README.md

**🧩 EEG Processing Pipeline**

1. Raw EEG Visualization
2. Channel Selection
3. Bandpass Filtering (0.5–45 Hz)
4. Common Average Referencing (CAR)
5. Independent Component Analysis (ICA)
6. ICLabel Artifact Classification
7. Clean EEG Reconstruction
8. Clean EEG Visualization
9. Power Spectral Density (PSD) Analysis
10. Band Power Extraction (Delta, Theta, Alpha, Beta, Gamma)
11. Downsampling
12. PSD Comparison Before and After Downsampling
13. Mean and Variance Comparison

## 📊 Features Extracted

### Frequency-Domain Features

* Power Spectral Density (PSD)
* Delta Band Power
* Theta Band Power
* Alpha Band Power
* Beta Band Power
* Gamma Band Power

### Statistical Features

* Mean
* Variance


## 📈 Visualizations

The pipeline generates:

* Raw EEG plots
* Filtered EEG
* Average Referenced EEG
* Clean EEG
* PSD plots
* Band Power Distribution
* PSD Before & After Downsampling
* Mean Comparison
* Variance Comparison


## 💻 Software Used

* MATLAB
* EEGLAB Toolbox
* ICLabel Plugin


## 🧠 Hardware

Emotiv EPOC X (14 Channels)

Channels Used:

AF3
F7
F3
FC5
T7
P7
O1
O2
P8
T8
FC6
F4
F8
AF4

## 📚 Key References

* Delorme, A., & Makeig, S. (2004). *EEGLAB: An open source toolbox for analysis of single-trial EEG dynamics.* Journal of Neuroscience Methods.
* Widmann, A., Schröger, E., & Maess, B. (2015). *Digital filter design for electrophysiological data.*
* Bigdely-Shamlo, N., et al. (2015). *PREP Pipeline.*
* Pion-Tonachini, L., et al. (2019). *ICLabel: Automated EEG Independent Component Classification.*
* Welch, P. D. (1967). *Power Spectral Density Estimation.*
* Gorjan, M., et al. (2022). *Removal of Movement-Induced EEG Artifacts.*


## 📌 Applications

* Brain–Computer Interface (BCI)
* Motor Imagery Classification
* Virtual Reality EEG Analysis
* Cognitive Workload Assessment
* Neurorehabilitation
* Stroke Rehabilitation Research


## 👩‍💻 Author

**Svastii Shrivastava**
B.Tech Artificial Intelligence & Data Science
Jabalpur Engineering College (JEC)
