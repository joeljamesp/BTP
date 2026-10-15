function pbc = fm_snr_update(pbc, y, p)
% Bayes update of the chance the channel is bad (pbc) from one noisy SNR measurement y.
Lg = exp(-(y - p.snr_mean(1))^2 / (2*p.snr_sigma^2));
Lb = exp(-(y - p.snr_mean(2))^2 / (2*p.snr_sigma^2));
pbc = pbc * Lb / (pbc * Lb + (1-pbc) * Lg);
end
