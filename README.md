# BTP: Intelligent Mode Selection for Dual-Functional Radar-Communication in Autonomous Vehicles

This is my (Joel James P, with Syeda Majida Bee) Bachelor Thesis Project at IIIT
Kottayam, under internal guide Dr. Ananth A and external guide Dr. Pradyumna Kumar
Bishoyi.

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

## Repo layout

```
review 1/
  simulation/     MATLAB implementation of the base paper's environment —
                  state space, action space, event-probability model (eq. 1),
                  reward function (eq. 3), discounted-return objective (eq. 4).
                  Phase 1 only: the environment itself, stopping right before
                  the DQN algorithm from Section IV.
  presentation/   The Beamer deck for BTP Review 1: review1_presentation.tex
                  is the source, review1_presentation.pdf is the built output.
                  architecture/ has the proposed-system architecture diagram
                  and the prompt used to generate it.
```

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
cd "review 1/presentation"
pdflatex review1_presentation.tex
```

The simulation is plain MATLAB, no toolboxes beyond base MATLAB:

```
cd "review 1/simulation"
main_demo
```
