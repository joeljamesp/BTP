# Channel estimator (belief filter) - the code we used

Copies of the files from `full_model_v2/code/world_and_estimator/` that make up the estimator and the little world it runs in. MATLAB; put this folder on the path and call `fm_step`.

The car cannot see the channel or the road, weather, speed and moving-object hazards. It keeps one number per item, the chance that item is unfavourable (the "belief"), and updates it every step.

## The estimator itself
- `fm_predict.m` - between steps each belief drifts back toward the item's everyday chance, because hidden states carry over only partly.
- `fm_sensor_update.m` - uses the free noisy hazard readings to sharpen the four hazard beliefs (Bayes rule).
- `fm_snr_update.m` - uses the one noisy signal-strength measurement taken when the car sends, to sharpen the channel belief (Bayes rule).
- `fm_uncertainty.m` - one "doubt" number from the hazard beliefs; the radar bonus in our reward is the doubt a scan clears.
- `fm_features.m` - what the learning car reads: the belief ('belief') or the latest raw readings trusted as true ('naive'), plus the queue.

## The world around it
- `fm_rho.m` - everyday chance of each hidden item being unfavourable.
- `fm_markov.m` - moves a hidden item to its next value (the carry-over).
- `fm_init.m` - starting state and starting belief.
- `fm_step.m` - one step: actions, packet queue, the estimator updates (lines 35-54), the hidden world moving on.
- `params.m` - all settings (carry-over 0.8, sensor error, channel measurement levels and noise).
- `state_event_probability.m` - chance a hazard event happens given the hazard readings.
- `fm_reward.m`, `fm_reward_lee.m` - called by `fm_step`; kept so the folder runs on its own. The reward is not part of the estimator.

Full project (training, evaluation, figures): `full_model_v2/`. Plain-language write-up: `meeting 4/channel estimator explained.pdf`.
