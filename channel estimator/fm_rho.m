function rho = fm_rho(p)
rho = [p.pc, 1-p.tau_r, 1-p.tau_w, 1-p.tau_v, 1-p.tau_m];
end
