function z = fm_markov(z, rho, phi)
z = double(rand(size(z)) < rho + phi .* (z - rho));
end
