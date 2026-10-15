function z = fm_markov(z, rho, phi)
% Next 0/1 value of each hidden component: stays near its long-run chance rho, with carry-over phi.
z = double(rand(size(z)) < rho + phi .* (z - rho));
end
