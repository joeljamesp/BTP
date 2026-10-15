function r = fm_reward_lee(a, event, b, A, p)
% Reward of Lee, Niyato, Guan, Kim (IEEE IV 2021), adapted to our environment (code: github.com/joleeson/JRC-AoI).
%   r = w_age * ( -sum_m m * A_m )  +  w_radar * ( -b )  if we communicated while a hazard occurred.
% A_m = age of information of tier m, weighted by urgency m = tier number. Their w_overflow = 0 in the released config,
% and they have no per-tier deadline penalty and no radar bonus. Defaults are their config: w_age 0.002, w_radar 10.
w_age = 0.002;  w_radar = 10;
if isfield(p, 'lee_w_age'),   w_age = p.lee_w_age;     end
if isfield(p, 'lee_w_radar'), w_radar = p.lee_w_radar; end
r = -w_age * sum((1:3) .* A);
if a == 0 && event, r = r - w_radar * b; end
end
