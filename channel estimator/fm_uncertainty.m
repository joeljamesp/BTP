function u = fm_uncertainty(pb)
q = pb(2:5);
u = mean(4 .* q .* (1 - q));
end
