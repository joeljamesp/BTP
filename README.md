# BTP: Intelligent Mode Selection for Dual-Functional Radar-Communication in Autonomous Vehicles

This is my (Joel James P, with Syeda Majida Bee) Bachelor Thesis Project at IIIT
Kottayam, under internal guide Dr. Ananth A and external guide Dr. Pradyumna Kumar
Bishoyi. The repo tracks everything from the first paper read-through to the final
defense — meeting notes, the Review 1 presentation, and the simulation code.

## What the project is actually about

Autonomous vehicles that share one radio for both radar sensing and V2I
communication have to decide, every time step, whether to sense or to talk. Our
base paper — iRDRC (Hieu, Hoang, Luong, Niyato, *IEEE WCL* 2020) — poses this as
an MDP and solves it with a DQN, but it leans on a few assumptions that don't hold
up in the real world: it assumes the vehicle already knows its channel and risk
state perfectly, it treats radar as a pure yes/no detector instead of something
that also reduces uncertainty, and it ignores anything about *which* packets are
actually urgent (deadlines, priority, QoS).

That gap is what we're building on. The plan is a belief-state formulation where
the vehicle reasons under uncertainty instead of assuming perfect knowledge, a
sensing action that's allowed to be more than binary, and a hierarchical
multi-armed-bandit controller (mode selection on top, packet scheduling
underneath) that stays safety-dominant the whole way through. Dr. Pradyumna's
feedback after our first discussion is what pushed the scheduling/QoS angle and
the hierarchical MAB direction specifically.

## Where things live

- `meeting 1/`, `meeting 2/`, `meeting 3/` — notes and slides from early
  paper-reading sessions with the guides, in roughly chronological order.
- `docs/iRDRC_Deep_Understanding.md` — a from-scratch, worked-through explanation
  of the base paper's Sections I–III (motivation, system model, the MDP
  formulation up through the reward function and discounted return), written for
  our own study, not copied from the paper.
- `review 1/` — the Beamer deck for BTP Review 1: `review1_presentation.tex` is
  the source, `review1_presentation.pdf` is the built output. The
  `architecture/` subfolder has the proposed-system architecture diagram and the
  prompt used to generate it.
- `simulation/` — MATLAB implementation of the base paper's environment: state
  space, action space, the event-probability model (eq. 1), the reward function
  (eq. 3), and the discounted-return objective (eq. 4). This is Phase 1 only —
  the environment itself, stopping right before the DQN algorithm from Section
  IV. `main_demo.m` runs a few naive policies (round-robin, always-communicate,
  always-radar) through it as a sanity check.
- `archive/` — older candidate BTP topics (audio codec work, modulation
  classification) that got explored before we settled on this direction. Kept
  around, not part of the current project.
- Root-level PDFs (`irdrc_explanation.pdf`, `irdrc_worked_example.pdf`,
  `irdrc_novelty_mapping.pdf`, etc.) and `files/` are working documents from the
  literature-review and novelty-verification pass before locking in the research
  gap.

## Where things stand

- **Phase 1 (done):** the base paper's environment is implemented in MATLAB —
  state space, action space, event model, reward function, discounted return.
- **Phase 2 (next):** finish the base paper properly — implement its DQN,
  reproduce its reported results, then stress-test it across scenarios to
  document exactly where it breaks (estimation noise, the rigid binary action,
  no QoS awareness).
- **Phase 3:** build out the belief-state estimator, the dual-role radar action,
  and the Level 1 mode-selection controller, and check whether it actually beats
  the Phase 2 baselines.
- **Phase 4:** add the Level 2 packet-scheduling controller, run the full
  hierarchical training and comparison against the base paper and the other
  literature, and write it all up.

## Building / running things

The presentation is a standard `pdflatex` Beamer build:

```
cd "review 1"
pdflatex review1_presentation.tex
```

The simulation is plain MATLAB, no toolboxes beyond base MATLAB:

```
cd simulation
main_demo
```
