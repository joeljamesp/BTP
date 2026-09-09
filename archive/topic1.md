# Self-Supervised Sim-to-Real Domain Adaptation for Automatic Modulation Classification (AMC)

## 1. Project Summary

This project is a B.Tech final year project (BTP) with a research paper as the primary
3-month deliverable (target: conference submission window, Oct–Nov). The paper phase is
**simulation-only** (public datasets, no hardware required). A separate later phase
(~4 months, outside the paper timeline) will validate the trained model on real SDR
hardware (HackRF/RTL-SDR) as an extension for the full-year BTP thesis.

**One-line pitch:** Most deep learning Automatic Modulation Classification (AMC) models
are trained and evaluated only on synthetic data and lose accuracy when they meet real,
hardware-captured signals. We use self-supervised pretraining across both synthetic and
real domains to close that gap using only a small amount of labeled real data — reducing
the dependence on expensive real-world labeled datasets.

---

## 2. Background: What is AMC?

Automatic Modulation Classification is the task of identifying the modulation scheme
(BPSK, QPSK, 8PSK, 16-QAM, 64-QAM, GFSK, AM-DSB, WBFM, etc.) of a received radio signal,
without prior knowledge of what was transmitted. It's a prerequisite step before actual
demodulation/decoding, and is used in:

- Cognitive radio / dynamic spectrum access
- Spectrum monitoring and regulatory enforcement
- Military signal intelligence and threat analysis
- IoT devices doing local spectrum sensing
- 5G/6G physical layer research (3GPP Release-19 AI/ML air-interface work)

**Standard pipeline:**
1. Input: raw IQ (in-phase/quadrature) samples of a received signal.
2. Older approach: extract hand-crafted statistical features (higher-order cumulants,
   cyclostationary features, constellation/wavelet images) → classical ML classifier.
3. Current deep learning approach: feed raw IQ (or a derived image representation)
   directly into a CNN / LSTM / Transformer / hybrid architecture.
4. Output: predicted modulation class label.

---

## 3. The Problem We're Addressing (Research Gap)

Deep learning AMC papers almost universally train and evaluate on **synthetic datasets**
(most commonly RadioML2016.10A/B), which model AWGN, multipath fading, and basic
oscillator offsets — but with idealized, simulator-generated impairments, not the
correlated quirks of a real physical radio chain (IQ imbalance, phase noise, PA
nonlinearity, sampling-rate mismatch as they actually co-occur in hardware).

Key facts backing this gap (from literature review, Aug 2026):

- A 2026 AI-for-wireless survey explicitly recommends that AMC papers report three
  numbers — synthetic in-distribution accuracy, synthetic out-of-distribution accuracy,
  and real over-the-air accuracy — because most currently report only the first one or
  two. This three-way comparison is rare in published work.
- RadioML2018.01A is itself partly composed of real over-the-air captured signals,
  giving us a ready-made "real-world" domain without needing our own hardware collection
  for the paper phase.
- Separately, self-supervised / contrastive learning for AMC (Mod-CL, SigDA, SSCL-AMC,
  EET-MoCo, GAF-MAE, transformer-contrastive frameworks) is an active 2024–2026 research
  thread — but every one of these papers pretrains and evaluates purely on synthetic
  data (RadioML). None of them test their self-supervised representations against real
  hardware-captured signals.
- Conversely, papers that do validate AMC on real over-the-air hardware (HackRF/USRP
  testbeds) all use plain supervised CNNs — none use self-supervised pretraining.

**The gap:** nobody has combined self-supervised pretraining (which reduces the need for
labeled data) with a genuine synthetic-to-real domain shift evaluation. This is our
opening.

---

## 4. Our Contribution / Novelty

**Core idea:** Pretrain a self-supervised (contrastive) encoder on a *mixture* of
unlabeled synthetic (RadioML2016) and unlabeled real (RadioML2018.01A) signals. Then
fine-tune a classifier head using abundant labeled synthetic data plus only a *small*
amount of labeled real data. Measure how much of the sim-to-real accuracy gap this
closes, compared to baselines.

This directly produces a practically useful, quotable result:
> "Self-supervised pretraining on mixed synthetic + real data closes X% of the
> sim-to-real accuracy gap using only Y% as much labeled real data as a fully
> supervised baseline."

### Experimental design

**Datasets (both public, no hardware needed for this phase):**
- `RadioML2016.10A` — synthetic domain. 11 modulation types, SNR -20 to 18 dB,
  220,000 signals, 128 samples per signal (2×128 IQ).
- `RadioML2018.01A` — includes real over-the-air captured signals. 24 modulation
  types, larger dataset (~2.5M samples). Treated as our "real-world" domain.

**Models to compare (ablation table):**
1. **Baseline A — Supervised only:** CNN/CNN-LSTM trained from scratch on labeled
   RadioML2016, tested cold on RadioML2018.01A. (Shows the raw sim-to-real drop.)
2. **Baseline B — SSL pretrained on synthetic only:** Contrastive pretraining
   (SimCLR-style, e.g. positive pairs from augmented/temporal segments of the same
   signal) using only unlabeled RadioML2016, then fine-tuned on labeled RadioML2016,
   tested on RadioML2018.01A.
3. **Ours — SSL pretrained on mixed domain:** Same contrastive pretraining, but using
   unlabeled data pooled from BOTH RadioML2016 and RadioML2018.01A, then fine-tuned
   on labeled RadioML2016 + a small labeled slice of RadioML2018.01A.

**Key metrics / figures for the paper:**
- Three-way accuracy table: synthetic in-distribution / synthetic out-of-distribution
  (held-out synthetic split with randomized channel params) / real OTA accuracy, for
  each of the three models above.
- **Labeled-data-budget curve:** real OTA accuracy vs. number of labeled real samples
  used in fine-tuning (e.g., 0, 10, 50, 100, 500, 1000 samples per class) — this is
  likely the headline figure, showing how few real labels our approach needs to match
  or approach a fully-supervised model.
- Per-modulation-class confusion matrices (some classes, e.g. 16-QAM vs 64-QAM, are
  historically harder to distinguish — worth separate analysis).
- Accuracy vs. SNR curves for each model.

**Novelty summary for the paper's contribution statement:**
1. First work (to our knowledge, as of Aug 2026 literature review) to combine
   self-supervised contrastive pretraining with an explicit synthetic-to-real domain
   shift evaluation for AMC.
2. Quantifies exactly how much labeled real-world data is needed to close the
   sim-to-real gap — directly actionable for practitioners who can't collect large
   labeled real datasets.
3. Sets up a natural real-hardware validation phase (Phase 2, below) using cheap SDR
   hardware, extending simulation results to genuine over-the-air deployment.

---

## 5. Timeline (Paper Phase — ~10 weeks, 2 people, ~10 hrs/day each)

| Weeks | Task |
|---|---|
| 1–2 | Environment setup (PyTorch, GNU Radio not needed yet since no hardware this phase). Download & preprocess RadioML2016.10A and RadioML2018.01A. Build data loaders. Train Baseline A (supervised CNN/CNN-LSTM) end-to-end — secure an early fallback result. |
| 3–5 | Build the self-supervised contrastive pretraining pipeline (SimCLR-style: augmentations = time shift, small AWGN, phase rotation, temporal segment pairs). Pretrain Baseline B (synthetic-only) and Ours (mixed-domain) encoders on unlabeled data. |
| 6–7 | Fine-tune all three models across varying labeled-real-data budgets. Generate the three-way accuracy table and the labeled-data-budget curve. |
| 8–9 | Ablations: which augmentations matter most, per-class confusion analysis, SNR robustness curves, sensitivity to pretraining epoch count / batch size / encoder architecture (CNN vs CNN-LSTM vs lightweight transformer). |
| 10 | Paper writing, figure polishing, buffer for reruns and reviewer-style self-critique. |

**Phase 2 (later, ~4 months, outside this deadline):** Deploy the final trained model on
real HackRF/RTL-SDR hardware for live over-the-air validation. Feeds into the full-year
BTP thesis as an implementation/validation chapter, and can become a follow-up/extended
journal version of the paper.

---

## 6. Suggested Repository Structure

```
amc-sim2real/
├── data/
│   ├── raw/                  # downloaded RadioML2016.10A, RadioML2018.01A
│   └── processed/            # preprocessed tensors, train/val/test splits
├── src/
│   ├── datasets.py           # dataset loading, splitting, IQ preprocessing
│   ├── augmentations.py      # SSL augmentations (time shift, AWGN, phase rot, segment pairs)
│   ├── models/
│   │   ├── encoder.py        # CNN / CNN-LSTM / lightweight transformer backbone
│   │   ├── ssl_head.py       # contrastive projection head (SimCLR-style)
│   │   └── classifier_head.py
│   ├── train_supervised.py   # Baseline A
│   ├── train_ssl_pretrain.py # Baselines B and Ours (pretraining step)
│   ├── finetune.py           # fine-tuning with variable labeled-data budgets
│   ├── evaluate.py           # three-way accuracy table, confusion matrices, SNR curves
│   └── utils.py
├── notebooks/                # exploratory analysis, plots for the paper
├── results/                  # saved metrics, figures, tables
├── configs/                  # experiment config files (yaml/json) per run
└── README.md                 # this file
```

---

## 7. Tech Stack

- Python, PyTorch (or TensorFlow if preferred — PyTorch recommended for easier
  contrastive learning implementations and community AMC-SSL reference code).
- Datasets: `RadioML2016.10A` and `RadioML2018.01A` (DeepSig, CC BY-NC-SA license —
  check citation/license requirements for the paper).
- Standard ML tooling: numpy, scikit-learn (for baseline metrics), matplotlib/seaborn
  (plots), Weights & Biases or TensorBoard (optional, for experiment tracking given the
  number of ablation runs).

---

## 8. Open Decisions to Finalize Before/During Implementation

- Exact encoder backbone: start with a simple CNN or CNN-LSTM (faster to get working
  and validate the pipeline), consider a lightweight transformer as an ablation later
  if time permits.
- Exact contrastive framework: SimCLR-style is the safest, best-documented starting
  point; can explore modulation-consistency-based positive pairs (à la Mod-CL) as a
  stretch goal if early results look promising and time allows.
- How to define "synthetic out-of-distribution" split — e.g., held-out SNR ranges or
  held-out channel parameter ranges within RadioML2016.
- Number of labeled-data-budget points for the curve (balance granularity vs. compute
  time — start coarse, e.g. 0/10/50/100/500/1000 samples/class, refine if time allows).

---

## 9. Key References to Cite / Build On

- O'Shea, T., West, N. — "Radio machine learning dataset generation with GNU Radio"
  (origin of RadioML).
- RadioML2018.01A dataset paper (DeepSig) — real OTA-captured signal source.
- Mod-CL — "Modulation Consistency-based Contrastive Learning for Self-Supervised AMC"
  (arXiv 2605.11875, 2026) — closest related SSL-for-AMC work, purely synthetic though.
- SigDA — "A Superimposed Domain Adaptation Framework for AMC" (IEEE TWC, 2024) —
  closest related domain-adaptation work.
- AI for Wireless Waveform Recognition survey (Electronics, 2026) — motivates the
  three-way accuracy reporting standard we adopt.
- CNN-LSTM Hybrid AMC over HackRF (arXiv 2511.21040, 2025) — template for eventual
  Phase 2 hardware validation methodology.

---

## 10. Deliverables Checklist

- [ ] Working data pipeline for RadioML2016.10A and RadioML2018.01A
- [ ] Baseline A (supervised) trained and evaluated
- [ ] SSL pretraining pipeline (Baselines B and Ours) implemented and trained
- [ ] Three-way accuracy table (synthetic-ID / synthetic-OOD / real-OTA) for all 3 models
- [ ] Labeled-data-budget curve (headline figure)
- [ ] Confusion matrices + SNR robustness curves
- [ ] Ablation results (augmentation choices, architecture variants)
- [ ] Paper draft (Intro, Related Work, Method, Experiments, Results, Conclusion)
- [ ] (Phase 2, later) Real hardware validation on HackRF/RTL-SDR