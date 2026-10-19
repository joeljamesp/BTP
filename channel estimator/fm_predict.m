function pb = fm_predict(pb, p)
rho = fm_rho(p);  phi = [p.phi_c, p.phi*ones(1,4)];
pb = rho + phi .* (pb - rho);
end
