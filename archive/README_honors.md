# SilentLink: FPGA-Based Adaptive Noise Cancellation Hub

**Honors Project 2026** | IIIT Kottayam  
**Student**: Joel James P (Roll: 2023BEC0010)  
**Supervisor**: Dr. Ananth A  
**Domain**: VLSI & Digital Communication

---

## 🎯 Project Overview

**SilentLink** is a universal USB-C hardware adapter that brings professional-grade **Active Noise Cancellation (ANC)** to any wired headphones, without requiring Bluetooth or software overhead. The device leverages an **FPGA-based processing core** to deliver real-time, zero-latency noise suppression through advanced DSP algorithms and adaptive filtering techniques.

### The Problem We Solve
- High-fidelity wired earphones lack ANC features
- Software-based ANC (smartphone OS, Zoom) drains battery and introduces unpredictable latency
- Wireless alternatives sacrifice audio quality via lossy compression
- **SilentLink** = Hardware-accelerated ANC in a dongle

### Key Features
✓ **Zero-latency processing** (Glass-to-glass < 10ms)  
✓ **FPGA-based acceleration** with 8-bit quantized inference  
✓ **Multiple ANC modes** (MVDR beamforming, CNN denoising, anti-noise synthesis)  
✓ **USB-C plug-and-play** compatibility  
✓ **Spatial audio processing** via 3-microphone array  

---

## 📁 Project Structure

```
e:\IIIT Kottayam\Honors\
├── abstract.tex                          # Project abstract & proposal
├── anc.py                               # Python spectral subtraction demo
├── input_48k.wav                        # Test audio input (48 kHz)
├── output.wav, output_cleaned.wav       # Denoised outputs
├── spectrogram_result.png               # Visualization of noise cancellation
│
├── phase1.tex                           # Phase 1 documentation
├── phase1_presentation.tex              # Presentation slides
│
├── research papers/                     # Academic references
│   ├── Audio_Pre-Processing_and_Beamforming_Implementatio.pdf
│   ├── A_Convolution-Neural-Network_Feedforward_Active-No.pdf
│   ├── Low-Power_FPGA_Realization_of_Lightweight_Active_N.pdf
│   └── research_paper_reference.pdf
│
├── review 1/                            # Honors Review 1 feedback & revisions
│   ├── review_sample.pdf
│   ├── review1.pdf, review1_edited.pdf, review1_final.pdf
│
├── review 2/                            # Honors Review 2 documentation
│   ├── chapter1.tex, chapter2.tex, ...
│   ├── main.tex
│   ├── presentation.tex
│   └── reprt/                           # Full report chapters
│       ├── chapter1.tex - chapter5.tex
│       └── main.tex
│
├── 11-03-2026/                          # FDLMS ANC Implementation (March 11 checkpoint)
│   ├── input_48k.wav
│   ├── honors (1).pdf
│   ├── fdlms_anc/                       # Frequency-Domain LMS Adaptive Cancellation
│   │   ├── fdlms_main.m                 # Main FDLMS pipeline
│   │   ├── fdlms_filter.m               # Frequency-domain filter implementation
│   │   ├── gen_signals.m                # Signal generation (clean + noise)
│   │   ├── plot_results.m               # Visualization of results
│   │   ├── noisy_input.wav              # Original signal with noise
│   │   ├── denoised_output.wav          # FDLMS-filtered output
│   │   ├── clean_reference.wav          # Clean reference signal
│   │   ├── fdlms_output.wav             # Final output
│   │   ├── output_1_noisy_input.wav
│   │   ├── output_2_denoised.wav
│   │   └── output_3_clean_reference.wav
│
├── mode 3A/                             # MVDR Beamforming + CNN Denoising
│   ├── output_1_speech_raw.wav          # Raw speech (no interference)
│   ├── output_2_interference_raw.wav    # Interference signal
│   ├── output_3_noisy_mic1.wav          # Noisy microphone array output
│   └── output_4_mvdr_cleaned.wav        # MVDR beamformed output
│
└── mode 3B/                             # CNN-Based Speech Denoising
    ├── README.md                        # Detailed mode documentation
    ├── README_v4.md
    ├── README_FINAL.tex
    ├── ANALYSIS.md
    ├── WHY_v6_WORKS.md
    ├── clean_testset_wav/               # Valentini dataset (51 files)
    │   ├── p232_001.wav through p232_059.wav
    │   └── [Clean speech samples for training/validation]
    └── [MATLAB training & evaluation scripts for CNN]
```

---

## 🛠️ Tools & Technologies Used

### **Audio Processing & DSP**
- **MATLAB/Octave** - Core implementation for FDLMS, MVDR beamforming, VAD
- **Python (NumPy, SciPy, Matplotlib)** - Spectral subtraction and signal visualization
- **librosa/soundfile** - Audio I/O and preprocessing

### **Filtering & Adaptive Algorithms**
- **Frequency-Domain LMS (FDLMS)** - Adaptive noise cancellation in frequency domain
  - Block length: 4096 samples
  - Filter length: 2048 taps
  - Step size (μ): 0.01 (learning), 0.001 (refinement)
  - SNR improvement: +6-8 dB
  
- **MVDR Beamforming** - Spatial filtering using 3-microphone array
  - Capon's minimum variance distortionless response
  - Steerable null steering for interference rejection
  
- **Spectral Subtraction** - Time-frequency noise reduction
  - FFT size: 1024, hop size: 512
  - Berouti spectral subtraction (α=2.0, β=0.002)
  - Over-subtraction parameters tuned for speech preservation

### **Deep Learning (CNN)**
- **Deep Neural Networks** - Speech denoising via magnitude prediction
  - Architecture: Encoder-bottleneck-decoder (32→64→128→64→32 channels)
  - Dataset: Valentini Noisy Speech Database (11,572 paired files)
  - Approach: Linear-domain noise subtraction
  - Target: +6 to +10 dB SNR improvement
  - **Status**: v7 Linear Noise model (training RMSE 0.15-0.19)

### **Voice Activity Detection (VAD)**
- **MATLAB implementation** - Real-time speech detection
  - Features: Short-Time Energy (STE), Zero-Crossing Rate (ZCR), Spectral Centroid (SC)
  - Voting-based classifier (2-of-3 criteria)
  - Adaptive thresholding based on noise floor
  - Routes to Mode 3A (speech) or Mode 3B (noise-only)

### **Hardware & VLSI**
- **Verilog/SystemVerilog** - RTL design for FPGA implementation
- **FPGA Target**: Quantized MAC units (8-bit fixed-point)
- **Communication**: USB Audio Class 2.0, I2S, I2C protocols
- **Latency Target**: < 10ms glass-to-glass

### **Documentation & Visualization**
- **LaTeX** - Academic papers, reports, presentations
- **Beamer** - Presentation slides with custom branding
- **Matplotlib** - Spectrograms, time-frequency plots, SNR curves

---

## 🔬 Core Algorithms Implemented

### **1. Frequency-Domain LMS (FDLMS) Adaptive Filter**
**Location**: `11-03-2026/fdlms_anc/`

Implements real-time adaptive noise cancellation in the frequency domain:

```matlab
% Key Parameters
N = 4096          % FFT block size
M = 2048          % Filter length (taps)
mu = 0.01         % Step size
Fs = 48000        % Sample rate (48 kHz)

% Two-pass algorithm
% Pass 1: Learn noise profile
% Pass 2: Apply converged filter with reduced learning rate
```

**Performance**:
- Input SNR: ~-6 dB (clearly audible noise)
- Output SNR: +1 to +2 dB (after convergence)
- SNR Improvement: +6-8 dB
- Processing frames: ~236 frames for full audio

---

### **2. MVDR Beamforming (Mode 3A)**
**Location**: `mode 3A/`

Spatial filtering using a 3-microphone array for directional noise suppression:
- Capon's minimum variance method
- Null-steering for interference rejection
- Output: Magnitude and phase-preserved audio

---

### **3. CNN-Based Speech Denoising (Mode 3B)**
**Location**: `mode 3B/`

Deep learning approach to suppress babble noise:

| Version | Approach | Status | SNR Result |
|---------|----------|--------|-----------|
| v2-v3 | Ideal Ratio Mask (IRM) | ❌ | -5.91 dB (collapsed to silence) |
| v4 | Direct Magnitude Prediction | ❌ | Negative SNR |
| v5 | Hybrid Magnitude-Mask | ❌ | +0.06 dB (scale bugs) |
| v6 | Log-domain Noise Subtraction | ❌ | +0.21 dB (domain mismatch) |
| **v7** | **Linear-domain Noise Subtraction** | ⏳ | **Expected +5 to +10 dB** |

**v7 Architecture**:
- Input: Normalized noisy log-magnitude [0, 1]
- Target: Linear noise magnitude (not log-space)
- Network: 32→64→128→64→32 channels
- Loss: MSE in normalized space
- Denormalization: Subtract in normalized space, denormalize after
- Training RMSE: 0.15-0.19 (excellent convergence)

---

### **4. Spectral Subtraction (Python)**
**Location**: `anc.py`

Classical frequency-domain noise reduction:

```python
# Parameters
FFT_SIZE = 1024
HOP_SIZE = 512
ALPHA = 2.0       # Over-subtraction factor
BETA = 0.002      # Floor threshold

# Berouti method:
# clean_power = max(noisy_power - α × noise_power, β × noisy_power)
```

---

### **5. Voice Activity Detection (VAD)**
**Location**: `vad engine/VAD_Engine.m`

Multi-feature speech detection:

| Feature | Purpose | Threshold |
|---------|---------|-----------|
| **STE** (Short-Time Energy) | Energy-based detection | 6× noise floor |
| **ZCR** (Zero-Crossing Rate) | Voiced/unvoiced variation | std > 0.05 |
| **SC** (Spectral Centroid) | Frequency band detection | > 1200 Hz |

**Decision Rule**: ≥2 of 3 criteria → SPEECH; else → NOISE ONLY

---

## 📊 Key Results & Milestones

### **Phase 1: FDLMS Adaptive Filtering** ✅ Complete
- ✓ Implemented 2-pass frequency-domain LMS algorithm
- ✓ Achieved +6-8 dB SNR improvement
- ✓ Verified convergence in 200+ frames
- ✓ Generated time-domain and frequency-domain visualizations

### **Phase 2: VAD Engine** ✅ Complete
- ✓ Adaptive thresholding based on noise floor
- ✓ Multi-criteria voting (STE, ZCR, SC)
- ✓ Real-time recording and feature extraction
- ✓ Routes to appropriate processing mode

### **Phase 3A: MVDR Beamforming** ✅ In Progress
- ✓ 3-microphone array spatial filtering
- ✓ Null-steering for interference suppression
- Outputs: `output_3_noisy_mic1.wav` → `output_4_mvdr_cleaned.wav`

### **Phase 3B: CNN Denoising** ⏳ Final Validation Pending
- ✓ v7 model trained (RMSE 0.15-0.19)
- ⏳ Inference fix applied (denormalization in correct space)
- 🎯 Target: +6 to +10 dB SNR improvement
- 📅 Deadline: April 9, 2026 (Honors Review 2)

### **Phase 4: FPGA RTL Design** 🔜 Planned
- Verilog implementation of DSP kernels
- 8-bit quantized MAC units
- I2S/USB Audio interfacing
- Latency optimization (<10ms)

---

## 📈 Experimental Datasets

### **Training Data**
- **Valentini Noisy Speech Database**: 11,572 paired clean/noisy samples
  - Sample rate: 48 kHz
  - Noise type: Real microphone-recorded human babble
  - Format: STFT with 256 samples/frame, 128-hop, 129 frequency bins

### **Test Signals**
- `input_48k.wav` - Clean speech reference (48 kHz)
- Generated synthetic noise (engine tone + broadband rumble at -6 dB SNR)
- Real microphone recordings from Honors Review sessions

---

## 🔧 How to Run

### **FDLMS Adaptive Filter**
```matlab
cd('C:\IIIT Kottayam\Honors\11-03-2026\fdlms_anc')
fdlms_main
% Generates: noisy_input.wav, denoised_output.wav, clean_reference.wav
% Displays time/frequency domain plots
```

### **VAD Engine**
```matlab
cd('C:\IIIT Kottayam\Honors\vad engine')
VAD_Engine
% Records 15 seconds of live audio
% Computes STE, ZCR, SC features
% Routes to Mode 3A or Mode 3B
```

### **Spectral Subtraction (Python)**
```bash
python anc.py
# Records 3 seconds of ambient noise for calibration
# Applies Berouti spectral subtraction
# Saves output.wav with cancellation applied
# Displays 4-stage spectrogram visualization
```

### **CNN Denoising (Mode 3B v7)**
```matlab
cd('C:\IIIT Kottayam\Honors\mode 3B')
Mode3B_v7_LinearNoise
% Loads Valentini dataset
% Trains network for 12 epochs (if not cached)
% Evaluates on validation set
% Displays mean SNR improvement
```

---

## 📚 Key Publications & References

Academic foundations for SilentLink:

1. **Audio Pre-Processing & Beamforming** - MVDR theory and implementation
2. **CNN Feedforward ANC** - Deep learning approaches to noise suppression
3. **FPGA Realization of Lightweight Active Noise** - Hardware acceleration strategies
4. **Convolution-Neural-Network Active Noise Control** - Modern ANC via deep learning

All papers stored in `research papers/` subdirectory.

---

## 🎓 Learning Outcomes

### **DSP Algorithms**
✓ Adaptive filtering (LMS, FDLMS)  
✓ Frequency-domain processing (FFT, STFT, spectral subtraction)  
✓ Beamforming (MVDR, spatial filtering)  
✓ Voice activity detection (multi-feature classification)  

### **Deep Learning**
✓ CNN architecture design for audio tasks  
✓ Domain consistency in ML training/inference  
✓ Handling sparse targets and loss function design  
✓ Normalization strategies for numerical stability  

### **FPGA & Hardware Design**
✓ Fixed-point quantization (8-bit)  
✓ Real-time latency constraints  
✓ USB Audio Class 2.0 protocol  
✓ I2S/TDM digital audio interfaces  

### **Problem-Solving Methodology**
✓ Systematic debugging of machine learning failures  
✓ Domain mismatch detection (linear vs. log space)  
✓ Validation of algorithmic assumptions  
✓ Iterative refinement through rapid prototyping  

---

## 📝 Documentation Files

| File | Purpose |
|------|---------|
| `abstract.tex` | Project proposal and overview |
| `phase1.tex` | Phase 1 technical documentation |
| `phase1_presentation.tex` | Presentation slides (Beamer) |
| `review 2/main.tex` | Full report with all chapters |
| `review 2/presentation.tex` | Honors Review 2 slides |
| `mode 3B/README.md` | Detailed CNN denoising methods & failures |
| `mode 3B/WHY_v6_WORKS.md` | Deep dive into v6 approach |
| `mode 3B/ANALYSIS.md` | Systematic error analysis |

---

## 🎯 Current Status & Next Steps

### ✅ Completed
- FDLMS adaptive filtering (+6-8 dB SNR improvement)
- VAD engine with multi-criteria detection
- Spectral subtraction baseline
- Research & literature review
- Phase 1 presentation & documentation

### ⏳ In Progress
- **CNN Mode 3B v7**: Final validation (inference fix applied, awaiting SNR verification)
- MVDR beamforming integration
- Cross-mode decision routing

### 🔜 Upcoming (Phase 2 & Beyond)
- FPGA RTL design in Verilog/SystemVerilog
- 8-bit quantization validation
- USB Audio Class 2.0 controller
- 3D-printed enclosure (DJI-style form factor)
- System integration & power optimization
- Live microphone array testing

---

## 👤 Author

**Joel James P**  
Roll Number: 2023BEC0010  
Department of Electronics and Communication Engineering  
IIIT Kottayam  
Email: joeljweb123@gmail.com

---

## 📅 Timeline

| Phase | Milestone | Target Date | Status |
|-------|-----------|------------|--------|
| Phase 1 | FPGA Prototyping & RTL Design | May 2026 | 📅 Planned |
| Phase 1 | Honors Review 2 Presentation | April 9, 2026 | ⏳ Final polish |
| Phase 2 | System-on-Chip Integration | Year 2 | 🔜 Future |
| Phase 2 | Hardware Productization | Year 2 | 🔜 Future |
| Phase 2 | 3D-printed Enclosure | Year 2 | 🔜 Future |

---

## 📞 Contact & Support

For questions about this project or its implementation:
- **Institution**: IIIT Kottayam, Kottayam, Kerala, India
- **Supervisor**: Dr. Ananth A
- **GitHub**: Available upon request

---

**Last Updated**: July 24, 2026  
**Project Status**: Active Development  
**License**: Honors Project (IIIT Kottayam)
