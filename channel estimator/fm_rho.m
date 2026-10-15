function rho = fm_rho(p)
% Long-run chance of the unfavorable value for [channel(bad) road weather speed moving-object].
rho = [p.pc, 1-p.tau_r, 1-p.tau_w, 1-p.tau_v, 1-p.tau_m];
end
