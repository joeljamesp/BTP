function r = fm_reward_lee(a, event, b, A, p)
w_age = 0.002;  w_radar = 10;
if isfield(p, 'lee_w_age'),   w_age = p.lee_w_age;     end
if isfield(p, 'lee_w_radar'), w_radar = p.lee_w_radar; end
r = -w_age * sum((1:3) .* A);
if a == 0 && event, r = r - w_radar * b; end
end
