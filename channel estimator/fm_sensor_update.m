function pb = fm_sensor_update(pb, o, err)
% Bayes update of the hazard beliefs (vector pb) from noisy 0/1 readings o that are wrong with chance err.
L1 = (1-err)*o + err*(1-o);          % chance of this reading if the true value is 1
L0 = err*o + (1-err)*(1-o);          % ... if the true value is 0
pb = pb .* L1 ./ (pb .* L1 + (1-pb) .* L0);
end
