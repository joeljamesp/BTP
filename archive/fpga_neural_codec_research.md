# FPGA-Native Neural-Augmented Audio Codec — BTP Project Plan

**Status**: candidate BTP topic, pivoted from `HALAC_ Hybrid Adaptive Low-Latency Audio
Codec.pdf` after its original novelty claim was found to overlap with existing work.
**This document**: folds a two-track literature/feasibility research pass (run
2026-08-12) into a full project plan — the idea, the research gap it targets, the steps
to actually build it, the research paper as a separate deliverable, and the resources
required.

---

## 1. The Idea

**Title**: FPGA-Native Neural-Augmented Audio Codec

**One-line pitch**: Every published neural or hybrid audio codec reports latency measured
on GPU/CPU. Nobody has demonstrated one actually running in real time on FPGA silicon
with genuinely measured hardware latency. This project builds one — a small causal
neural network layered on a classical codec core, deployed and measured on real FPGA
hardware — with that measured latency number as the headline result.

**Origin**: this pivots away from the original HALAC idea (a from-scratch hybrid codec
competing on bitrate/quality against LDAC/Opus/LC3), whose novelty claim didn't hold up
against existing work — 3GPP EVS and MPEG-D USAC already do classifier-driven mode
switching between speech- and music-optimized coding paths, and Qualcomm's aptX
Adaptive/Lossless already do adaptive high-fidelity low-latency wireless streaming. The
pivot keeps HALAC's classical DSP core (MDCT/psychoacoustic coding) but moves the
research contribution from "smarter mode switching" to "getting a neural-augmented codec
onto real constrained hardware with a number you can actually measure."

**Core approach**:
1. A small, fully causal neural network (LACE/NoLACE pattern — proven, already shipped in
   Opus 1.5, ~300K parameters) that **never touches raw audio directly** — it predicts
   filter coefficients that steer a classical LPC/MDCT codec's own prediction filters.
2. Quantize that network (INT8/INT16 fixed-point) and deploy it, alongside the classical
   codec core, onto real FPGA hardware.
3. Measure real, on-chip, end-to-end encode+decode latency — not a simulation, not a
   synthesis-tool estimate.

**Why this connects to existing work already underway**: this directly reuses skills
being built in the separate SilentLink Honors project — FPGA toolchain experience,
8-bit-quantized MAC unit design, and real-time audio DSP (FDLMS, psychoacoustic
modeling) — turning Honors and BTP into one continuous research arc instead of two
disconnected efforts.

**Team**: Joel (primary), Adithya (secondary researcher), advisor Dr. Ananth A — same
advisor as the Honors SilentLink project.

---

## 2. Research Gap

### 2.1 The gap being targeted

No neural or hybrid (classical DSP + neural network) audio/speech **codec** — meaning
something with both an encoder and decoder that compresses arbitrary input audio to a
bitstream and reconstructs it — has been demonstrated running in real time on FPGA with
measured (not synthesized/estimated) hardware latency, anywhere, as of an Aug 2026
literature search covering ~75 targeted queries across two independent research passes.

### 2.2 What was actually found (prior art landscape)

**Closest near-miss — read this one in full before finalizing scope**: arXiv:2606.04221
(July 2026), "Feasibility of Time-Domain DNN-Based Speech Enhancement on Embedded FPGA
for Hearing Aids." A causal 1.5M-parameter time-domain CNN (SuDoRM-RF++ 0.25x), deployed
on an AMD Kria KV260 (Zynq UltraScale+ MPSoC), 16-bit fixed-point, **hand-written Vitis
HLS** (no automated toolchain). Result: **9.7ms measured first-sample hardware latency**,
PESQ 2.41 / STOI 0.93. This is speech *enhancement/denoising* — no bitstream, no
compression — so it isn't directly competing prior art, but it's architecturally almost
identical to what SilentLink is already attempting, making it simultaneously the best
available methodology template and a signal that this adjacent space is being actively
worked.

| Category | What was found | Relevance |
|---|---|---|
| Neural audio, real measured hardware latency (not codecs) | TinyVocos (MCU, not FPGA); the KV260 hearing-aid paper above; Intel WaveNet-on-Stratix-10-NX whitepaper (unverifiable primary source, 403s) | Adjacent, none are compression codecs |
| Classical (non-neural) codecs on FPGA | Codec2 on Cyclone IV (IEEE CSCI 2021); G.729.1 on Altera Nios II (2009) | Confirms "codec on FPGA" as an engineering pattern is old — only the neural piece is missing |
| Learned codec on FPGA, real measured latency — **for images** | F-LIC (arXiv:2503.04832, March 2025), Xilinx ZCU102, 43 FPS, real measured PSNR/energy | Proves the exact pattern works for a sibling modality — the audio instantiation specifically is what's missing |
| Hybrid classifier + classical MDCT/LPC, on FPGA | **Nothing found** | Equally open, and likely the more tractable framing for a BTP scope |
| Simulation-only or unverifiable hardware claims | Spiking Vocos (arXiv:2509.13049) — no evidence of real neuromorphic hardware run | Excluded as not real prior art |

### 2.3 Search coverage caveats — act on this before fully committing

No direct IEEE Xplore, Google Scholar, or ACM Digital Library access in this research
pass; no patent database search (Qualcomm/MediaTek/Realtek/HiSilicon file audio-chip
patents that don't surface in academic search); no non-English venues checked.
**Recommendation**: before committing months of work, have Joel or Dr. Ananth run one
institutional-access pass on "neural audio codec FPGA hardware accelerator" plus
forward-citation-chasing from AudioDec/F-LIC/LPCNet on Google Scholar, and a quick
patent-landscape check on major audio-SoC vendors. This is exactly the kind of blind spot
that already weakened the original HALAC novelty claim once (missed EVS/USAC/aptX
Adaptive) — cheap insurance against a repeat.

---

## 3. Project Completion Steps (Implementation Roadmap)

Ordered by dependency, not locked to specific calendar dates.

**Phase 1 — Classical Codec Core (Software)**
- Implement the classical LPC/MDCT codec baseline in software (this reuses HALAC's
  MDCT/psychoacoustic groundwork and Honors-project DSP experience).
- Verify correctness: lossless reconstruction before quantization, then baseline
  quantized quality with no neural component at all — this is the "classical-only"
  comparison point for every later result.

**Phase 2 — Neural Side-Network (Software, Floating-Point)**
- Implement a LACE/NoLACE-pattern network: small, fully causal, predicts filter
  coefficients (not raw audio) over the Phase 1 codec core.
- Train on a labeled/unlabeled mix of speech and music audio (see §5 for dataset list).
- Validate in floating-point simulation: does the neural-augmented path measurably beat
  the classical-only baseline on objective quality metrics (PESQ/STOI/PEAQ)? This must be
  true before spending any effort on hardware deployment.

**Phase 3 — Quantization**
- Quantize the trained network to INT8/INT16 fixed-point (quantization-aware training via
  Brevitas, or manual fixed-point conversion).
- Re-validate quality in simulation post-quantization — confirm the coefficient-prediction
  design tolerates quantization noise as expected (this is the specific risk the
  LACE-style architecture was chosen to avoid; see §3 of the original research notes for
  why raw-waveform-synthesis architectures like LPCNet/FARGAN were ruled out here).

**Phase 4 — Hardware Deployment**
- Select board: PYNQ-Z2 (cheaper, best student documentation, sufficient for a
  ~72K-weight-class network) or Kria KV260 (matches the closest real precedent exactly,
  comfortable headroom for the ~300K-parameter LACE-sized network) — see §5 for
  cost/spec detail.
- Implement the classical codec core in RTL/HLS, reusing SilentLink's FPGA toolchain
  where possible.
- Implement the quantized neural side-network via **hand-written Vitis HLS** — published
  practice in this exact niche (the KV260 hearing-aid paper) did not use an automated
  toolchain (hls4ml/FINN don't handle this class of model well; see the original
  feasibility research notes for the specific tooling gaps), so budget engineering time
  accordingly rather than assuming a push-button flow.
- Integrate the encoder+decoder pipeline on-chip, streaming, matching real audio sample
  rates.

**Phase 5 — Measurement & Evaluation**
- Measure real, on-chip, end-to-end encode+decode latency (the headline number).
- Measure resource utilization (LUTs, DSP slices, BRAM/URAM) and power draw.
- Run objective quality metrics (PESQ/STOI, and PEAQ if feasible) on hardware-processed
  audio, compared against: (a) the Phase 1 classical-only baseline on the same hardware,
  and (b) CPU/GPU-only versions of the same neural-augmented pipeline, to make the
  "hardware-native" contribution concrete and measurable.

**Phase 6 — Optimization**
- Tune the latency/quality trade-off (e.g., weight-caching strategy — on-chip BRAM
  capacity for weight storage was found to be the binding constraint in the closest real
  precedent, not raw DSP compute).
- Iterate on anything that falls short of target latency or quality.

---

## 4. Research Paper Plan (Separate Deliverable)

The paper is a distinct deliverable from the implementation above — drafting starts once
Phase 5 produces a real measured latency number, since that number is the paper's central
claim.

**Structure**:
1. **Introduction** — the gap (§2.1): every published neural/hybrid codec latency figure
   is GPU/CPU-measured, not real-hardware-measured
2. **Related Work** — classical FPGA codecs (Codec2, G.729.1), learned-codec-on-FPGA for
   images (F-LIC), the closest near-miss (arXiv:2606.04221 — explicit differentiation:
   enhancement vs. compression), LACE/NoLACE as the architectural basis
3. **Method** — codec core design, neural side-network architecture and training,
   quantization approach, hardware implementation (board, HLS/RTL structure, pipeline
   integration)
4. **Evaluation** — measured hardware latency (headline figure), resource utilization
   table, power draw, objective quality metrics vs. classical-only and CPU/GPU baselines
5. **Discussion** — what made real-hardware deployment hard in practice (tooling gaps,
   quantization behavior actually observed vs. predicted), limitations
6. **Conclusion & Future Work** — multi-channel, other codec cores, closing the loop with
   the SilentLink Honors project

**Key figures/tables the paper needs**:
- Architecture/pipeline block diagram
- Latency comparison table: this work (real hardware) vs. CPU/GPU baselines vs. the
  closest FPGA precedent (arXiv:2606.04221)
- Resource utilization table (LUTs/DSP/BRAM/URAM, power)
- Quality metric table (PESQ/STOI) — neural-augmented vs. classical-only, same hardware

**Before finalizing the novelty paragraph**: complete the institutional-access literature
check from §2.3, and read arXiv:2606.04221 in full.

**Deliverables checklist**:
- [ ] Classical codec core, software baseline, verified
- [ ] LACE-pattern neural side-network trained, floating-point quality validated
- [ ] Quantized (INT8/INT16) network, quality re-validated
- [ ] Full encoder+decoder pipeline running on FPGA
- [ ] Measured hardware latency, resource utilization, power draw
- [ ] Objective quality metrics vs. classical-only and CPU/GPU baselines
- [ ] Institutional-access literature re-check (§2.3) completed
- [ ] Paper draft (Intro → Conclusion)

---

## 5. Resources Required

**Hardware**: PYNQ-Z2 (~$150–250, Zynq-7020, ~53K LUTs / 220 DSP / ~4.9Mb BRAM) or Kria
KV260 (~$200–450, Zynq UltraScale+, ~230K LUTs / ~1.2–1.7K DSP / ~11Mb BRAM + 27Mb URAM —
matches the closest real precedent exactly). **Check first** whether a board already
acquired for the SilentLink Honors project can be shared/reused before purchasing a
second one.

**Software/tools**: Vitis HLS / Vivado for FPGA implementation; PyTorch + Brevitas for
training and quantization-aware training of the neural side-network; Opus reference
source code as the LACE/NoLACE architectural and comparison baseline; PEAQ/PESQ/STOI
implementations for objective evaluation.

**Datasets** (training and evaluation audio, reused from the original HALAC resource
list): EBU SQAM (Sound Quality Assessment Material), speech corpora (LibriSpeech, VCTK),
diverse music samples. Total volume ~50GB expected.

**Compute**: standard development workstation (16GB+ RAM); GPU helpful but not strictly
required for training given the neural side-network is small (~300K parameters, unlike a
full end-to-end neural codec).

**Team**: Joel (primary), Adithya (secondary researcher), advisor Dr. Ananth A.

**Evaluation logistics**: objective metrics (PESQ/STOI/PEAQ) are sufficient for the core
claims in this scope. A lightweight subjective listening comparison is optional and can
be added later if time permits — the full 20+-subject MUSHRA infrastructure from the
original HALAC plan is not required to support this project's headline claim (measured
hardware latency), which lowers logistics burden relative to the original HALAC scope.
