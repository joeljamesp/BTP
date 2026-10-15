function pb = fm_predict(pb, p)
% Belief for the next step: each hidden value drifts back toward its long-run chance at rate (1 - phi).
rho = fm_rho(p);  phi = [p.phi_c, p.phi*ones(1,4)];
pb = rho + phi .* (pb - rho);
end
