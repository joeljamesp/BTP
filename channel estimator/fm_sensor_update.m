function pb = fm_sensor_update(pb, o, err)
L1 = (1-err)*o + err*(1-o);
L0 = err*o + (1-err)*(1-o);
pb = pb .* L1 ./ (pb .* L1 + (1-pb) .* L0);
end
