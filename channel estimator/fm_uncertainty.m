function u = fm_uncertainty(pb)
% How unsure the car is about the four hazard readings: 0 = certain, 1 = a coin flip on every reading.
q = pb(2:5);
u = mean(4 .* q .* (1 - q));
end
