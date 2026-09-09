# AMC Sim-to-Real Self-Supervised Domain Adaptation — BTP Project Plan

**Status**: candidate BTP topic, not yet finalized. Source idea: `topic1.md`.
**This document**: folds an independent literature-verification pass (run 2026-08-12)
into a full project plan — the idea, the research gap it targets, the steps to actually
build it, the research paper as a separate deliverable, and the resources required.

---

## 1. The Idea

**Title**: Self-Supervised Sim-to-Real Domain Adaptation for Automatic Modulation
Classification (AMC)

**One-line pitch**: Most deep learning AMC models are trained and evaluated only on
synthetic radio signal data, and lose accuracy when they meet real, hardware-captured
signals. This project uses self-supervised pretraining across both synthetic and real
domains to close that gap using only a small amount of labeled real data — reducing
dependence on expensive real-world labeled datasets.

**What AMC is, briefly**: Automatic Modulation Classification identifies the modulation
scheme (BPSK, QPSK, 8PSK, 16-QAM, 64-QAM, GFSK, AM-DSB, WBFM, etc.) of a received radio
signal without prior knowledge of what was transmitted. It's a prerequisite step before
demodulation, used in cognitive radio / dynamic spectrum access, spectrum monitoring,
signal intelligence, IoT spectrum sensing, and 5G/6G physical-layer research.

**Core approach**:
1. Pretrain a self-supervised contrastive encoder (SimCLR-style — augmentations: time
   shift, small AWGN, phase rotation, temporal segment pairs) on a *mixture* of unlabeled
   synthetic (RadioML2016.10A) and unlabeled real over-the-air (RadioML2018.01A) IQ
   signals.
2. Fine-tune a classifier head using abundant labeled synthetic data plus only a *small*
   amount of labeled real data.
3. Measure how much of the sim-to-real accuracy gap this closes, against two baselines:
   a supervised-only model, and an SSL model pretrained on synthetic data only.

**Target headline result**: *"Self-supervised pretraining on mixed synthetic + real data
closes X% of the sim-to-real accuracy gap using only Y% as much labeled real data as a
fully supervised baseline."*

**Team**: 2 people, target ~10 hrs/day each during the active build phase. Advisor: Dr.
Ananth A.

---

## 2. Research Gap

### 2.1 The gap being targeted

Deep learning AMC papers almost universally train and evaluate on synthetic datasets
(mainly RadioML2016.10A/B) — idealized simulator impairments, not the correlated quirks
of a real physical radio chain (IQ imbalance, phase noise, PA nonlinearity, sampling-rate
mismatch as they actually co-occur in hardware). Separately, self-supervised/contrastive
learning for AMC is an active 2024–2026 research thread, but every such paper pretrains
*and* evaluates purely on synthetic RadioML data. Conversely, papers that validate AMC on
real over-the-air hardware (HackRF/USRP/RTL-SDR testbeds) all use plain supervised CNNs.
**Nobody has combined self-supervised pretraining with a genuine synthetic-to-real domain
shift evaluation for AMC** — that combination is this project's opening.

### 2.2 Citation verification (independently checked, corrected where needed)

| # | Reference | Verified role in the project |
|---|---|---|
| 1 | Wang, Chenxu et al., "Mod-CL: Modulation Consistency-based Contrastive Learning for Self-Supervised AMC," arXiv:2605.11875 (2026) | Confirmed real. SSL via intra-instance temporal-segment consistency, evaluated on RadioML only — no real-hardware/OTA evaluation. Cite as synthetic-only SSL prior art. |
| 2 | "A Superimposed Domain Adaptation Framework for AMC" (SigDA), IEEE TWC vol. 23(10), pp. 13159–13172, 2024, doc 10557536 | Confirmed real. **Correction from original draft**: its "domain shift" is combined *simulated* impairments (channel type, SNR, freq offset stacked), not a real-hardware gap; uses adversarial feature alignment (M2SFE+SFPA), not SSL. Cite precisely as this, not as a sim-to-real-hardware paper. |
| 3 | "AI for Wireless Waveform Recognition: A Survey from a Component Perspective," Electronics 15(10):2112, May 2026 | Confirmed real; **full title corrected** (original draft dropped the subtitle). Addresses sim-to-real generalization and OOD failure modes. The "report three accuracy numbers" recommendation should be quoted directly from the PDF when writing the paper, not paraphrased — could not be independently verified verbatim. |
| 4 | Padhya, Acharya, Dahal, Kshatri, "CNN-LSTM Hybrid Architecture for Over-the-Air AMC Using SDR," arXiv:2511.21040, Nov 2025 | Confirmed real. **Correction from original draft**: receiver is **RTL-SDR, not HackRF** — "HackRF" doesn't appear in the paper. Purely supervised, tested on recorded OTA I/Q (~86%) and live capture (~80%). |
| 5 | O'Shea, T., West, N., "Radio Machine Learning Dataset Generation with GNU Radio," GRCon 2016 | Confirmed real — canonical RadioML origin paper. |
| 6 | RadioML2018.01A dataset (DeepSig) | Confirmed: 24 modulation classes × 26 SNR levels (−20 to +30 dB) × 4096 examples ≈ 2.56M IQ frames (1024 samples each), generated via real RF hardware (USRP). Documented in O'Shea, Roy & Clancy, IEEE JSTSP 12(1):168–179, 2018 / arXiv:1712.04578. |
| 7 | RadioML2016.10A dataset | Confirmed exactly: 11 modulations, SNR −20 to 18 dB (2 dB steps), 220,000 signals, 128 complex samples/signal, purely synthetic. |

Named synthetic-only SSL prior art — SSCL-AMC (ICASSP 2025, doc 10890093), EET-MoCo (IEEE
doc 10884924), GAF-MAE (IEEE doc 10261289) — all confirmed to exist; none evaluate on
real-hardware/OTA data. **Nothing checked in this citation list is fabricated.**

### 2.3 Novelty verdict

The exact combination claimed — SSL/contrastive pretraining on mixed synthetic+real IQ
data, fine-tuned on abundant synthetic + scarce real labels, with an explicit three-way
accuracy comparison (synthetic-ID / synthetic-OOD / real-OTA) against a supervised-only
and a synthetic-only-SSL baseline — **does not appear to exist yet as a single published
paper**. The margin is thinner than it looks, though — closest near-misses found:

| Work | Why it's close | Why it doesn't fully overlap |
|---|---|---|
| arXiv 2206.12967 (2022) | Explicitly measures sim-to-real gap for RF signal classification | Purely supervised, no SSL |
| **arXiv 2510.00589 (Oct 2025)** — "Signal Classification Recovery Across Domains Using UDA" | **Closest conceptual cousin** — explicit simulated-vs-OTA domain alignment | Uses adversarial/statistical UDA (STAR, JAN), not SSL contrastive pretraining |
| Sensors 26(10):2945 (May 2026) | Near-identical evaluation framing (synthetic-to-OTA) | OFDM-specific, purely supervised CNN |
| arXiv 2510.23186 (Oct 2025) | Synthetic-pretrained embeddings validated on real RF | Supervised loss (ArcFace/Norm-Softmax), broader-than-AMC scope |
| arXiv 2509.03077 | SSL momentum-contrastive + AMC | Pretrains *and* fine-tunes entirely on real data — mirror image of this project's setup |
| **Nature Communications s41467-025-60921-z (2025)** | **Highest-priority full-text read** — title proximity ("multi-representation domain... contrastive learning... unsupervised AMC") is the biggest risk | Paywalled; "domain" likely means signal-representation domain, not synthetic-vs-real — needs first-hand confirmation before ruling it out |

**Terminology trap**: in this subfield, "domain"/"cross-domain" in paper titles usually
means signal-representation domain (IQ/AP/ACF/time/frequency) or channel-condition domain
(SNR, fading) — not synthetic-vs-real-hardware. Judge relevance by full text, not titles.

**Verdict**: novelty survives as of Aug 2026, but it's a combination-of-existing-pieces
novelty in a crowded, fast-moving space (5–6 closely related 2025–2026 papers surfaced in
one research session). Real risk of a reviewer asking "how is this different from X."

### 2.4 Dataset access and license

Both datasets downloadable at `deepsig.ai/datasets` (note: `.ai`, not `.io`), no
registration gate, CC BY-NC-SA 4.0 license — compatible with academic/conference
publication (NC/SA only bind commercial use or redistributing a derivative *dataset*).
DeepSig's own site flags these as legacy sets with "known errata" and recommends real OTA
or custom data instead — worth a one-line acknowledgment in the paper's motivation
section rather than ignoring it.

---

## 3. Project Completion Steps (Implementation Roadmap)

Ordered by dependency, not locked to specific calendar dates.

**Phase 1 — Setup & Data Foundation**
- Set up PyTorch environment; no SDR/GNU Radio needed yet (paper phase is simulation-only).
- Download and preprocess RadioML2016.10A and RadioML2018.01A; build data loaders and
  train/val/test splits, including a held-out synthetic split (by SNR range or channel
  parameter range) for the "synthetic-OOD" evaluation arm.
- Train **Baseline A** (supervised CNN/CNN-LSTM from scratch on labeled RadioML2016,
  tested cold on RadioML2018.01A) end-to-end — secures an early fallback result and
  validates the pipeline before anything more complex is built.

**Phase 2 — Self-Supervised Pretraining Pipeline**
- Build the SimCLR-style contrastive pretraining pipeline (augmentations: time shift,
  small AWGN, phase rotation, temporal segment pairs).
- Pretrain **Baseline B** (synthetic-only unlabeled data) and **Ours** (pooled unlabeled
  synthetic + real data) encoders.

**Phase 3 — Fine-Tuning & Main Results**
- Fine-tune all three models across varying labeled-real-data budgets (e.g., 0, 10, 50,
  100, 500, 1000 samples/class — start coarse, refine if time allows).
- Generate the three-way accuracy table and the labeled-data-budget curve (this is the
  headline result).

**Phase 4 — Ablations & Robustness Analysis**
- Which augmentations matter most; per-class confusion analysis (16-QAM vs 64-QAM are
  historically hard to separate); accuracy-vs-SNR curves; sensitivity to pretraining
  epoch count, batch size, encoder architecture (CNN vs CNN-LSTM vs lightweight
  transformer, as time allows).

**Phase 5 — Read the near-miss papers, finalize differentiation** (see §2.3)
- Full-text read of the Nature Communications paper and arXiv 2510.00589 before writing
  the novelty paragraph; explicitly differentiate in the intro.

**Phase 6 — Later, separate track (thesis extension, not part of the paper phase)**
- Deploy the final trained model on real HackRF/RTL-SDR hardware for live over-the-air
  validation. Feeds into the full-year BTP thesis as an implementation/validation
  chapter, and can become a follow-up/extended journal version of the paper.

---

## 4. Research Paper Plan (Separate Deliverable)

The paper is a distinct deliverable from the implementation above — writing starts once
Phase 3's headline result exists, and Phase 4/5 findings feed in as they land.

**Structure**:
1. **Introduction** — problem statement, the research gap (§2.1), contributions summary
2. **Related Work** — synthetic-only SSL-for-AMC (Mod-CL, SSCL-AMC, EET-MoCo, GAF-MAE),
   real-hardware supervised AMC (the RTL-SDR CNN-LSTM paper), domain-adaptation-for-AMC
   (SigDA, arXiv 2510.00589) — explicit differentiation paragraph against the Nature
   Communications paper and arXiv 2510.00589 specifically
3. **Method** — contrastive pretraining setup, mixed-domain pooling strategy,
   fine-tuning protocol across labeled-data budgets
4. **Experiments** — datasets, splits (incl. synthetic-OOD definition), baselines, metrics
5. **Results** — three-way accuracy table; labeled-data-budget curve (headline figure);
   per-class confusion matrices; accuracy-vs-SNR curves; ablations
6. **Discussion** — practical implications (how few real labels are actually needed),
   limitations, acknowledgment of RadioML's known-errata caveat
7. **Conclusion & Future Work** — points to the Phase 6 hardware validation as future work

**Citation fixes to apply before drafting** (see §2.2): RTL-SDR not HackRF; full survey
title; precise (not overstated) description of SigDA.

**Deliverables checklist**:
- [ ] Working data pipeline (RadioML2016.10A + RadioML2018.01A)
- [ ] Baseline A (supervised) trained and evaluated
- [ ] SSL pretraining pipeline (Baselines B and Ours) implemented and trained
- [ ] Three-way accuracy table for all 3 models
- [ ] Labeled-data-budget curve (headline figure)
- [ ] Confusion matrices + SNR robustness curves
- [ ] Ablation results
- [ ] Full-text differentiation against the Nature Comms paper and arXiv 2510.00589
- [ ] Paper draft (Intro → Conclusion)
- [ ] (Later, separate) Real hardware validation on HackRF/RTL-SDR

---

## 5. Resources Required

**Datasets**: RadioML2016.10A, RadioML2018.01A — both public, free, `deepsig.ai/datasets`,
CC BY-NC-SA 4.0 (see §2.4).

**Compute**: A single modern GPU is sufficient for contrastive pretraining + fine-tuning
at this data scale (RadioML signals are small — 128 or 1024 samples each); no
multi-node/large-cluster requirement expected. CPU-only would be a serious bottleneck for
the contrastive pretraining stage specifically.

**Software/tools**: Python, PyTorch (preferred over TensorFlow for easier access to
community contrastive-learning reference code); numpy/scikit-learn for baseline metrics;
matplotlib/seaborn for figures; Weights & Biases or TensorBoard for tracking the number of
ablation runs in Phase 4.

**Team**: 2 people, advisor Dr. Ananth A.

**Phase 6 (later, separate)**: HackRF or RTL-SDR hardware for the real-world validation
extension — not required for the paper-phase deliverables above.
