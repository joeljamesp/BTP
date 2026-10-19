function [S, r, info] = fm_step(S, a, p)

x = S.x;  c = S.c;  b = sum(x);
P = state_event_probability(x(1), x(2), x(3), x(4), p);
event = rand() < P;
delivered = zeros(1,3);  k = 0;  capv = 0;

if a == 0
    cap = p.nu1; if c == 1, cap = p.nu2; end
    capv = cap;
    [~, order] = sortrows([-S.tier(:) S.dl(:)]);
    k = min(cap, numel(order));  served = order(1:k);
    for j = 1:3
        sj = served(S.tier(served) == j);
        if ~isempty(sj), S.A(j) = p.dl_by_tier(j) - min(S.dl(sj)); end
    end
    for j = 1:3, delivered(j) = sum(S.tier(served) == j); end
    S.tier(served) = [];  S.dl(served) = [];
end

S.A = S.A + 1;
S.dl = S.dl - 1;
gone = S.dl <= 0;  expired = zeros(1,3);
for j = 1:3, expired(j) = sum(S.tier(gone) == j); end
S.tier(gone) = [];  S.dl(gone) = [];

n = poissrnd(p.lambda_d);  overflow = 0;  arrived = zeros(1,3);
for i = 1:n
    j = find(rand() < cumsum(p.tier_probs), 1);  arrived(j) = arrived(j) + 1;
    if numel(S.tier) < p.D, S.tier(end+1) = j;  S.dl(end+1) = p.dl_by_tier(j);
    else, overflow = overflow + 1; end
end

pb = S.pb;
if a == 1
    pb(2:5) = x;
else
    y = p.snr_mean(c+1) + p.snr_sigma * randn();
    pb(1) = fm_snr_update(pb(1), y, p);
    S.last_chat = double(y < mean(p.snr_mean));
end

pb = fm_predict(pb, p);
u = fm_uncertainty(fm_predict(S.pb, p));  u_next = fm_uncertainty(pb);
r = fm_reward(a, c, event, b, k, expired, u, u_next, p);
if isfield(p, 'reward_style') && strcmp(p.reward_style, 'lee'), r = fm_reward_lee(a, event, b, S.A, p); end
rho = fm_rho(p);
S.c = fm_markov(S.c, rho(1), p.phi_c);
S.x = fm_markov(S.x, rho(2:5), p.phi);
o = S.x;  flip = rand(1,4) < p.sensor_err;  o(flip) = 1 - o(flip);
pb(2:5) = fm_sensor_update(pb(2:5), o, p.sensor_err);
S.pb = pb;  S.last_o = o;

pp = p;  pp.r5 = 0;  pp.pen_by_tier = [0 0 0];
pn = p;  pn.r5 = p.novel_r5;  pn.pen_by_tier = p.novel_pen;
info.r_paper = fm_reward(a, c, event, b, k, expired, u, u_next, pp);
info.r_novel = fm_reward(a, c, event, b, k, expired, u, u_next, pn);
info.cap = capv;  info.c = c;  info.b = b;
info.miss_unit = double(a == 0 && event) * (1 + (b - 1) * (isfield(p, 'reward_style') && strcmp(p.reward_style, 'lee')));
info.event = event;  info.r_lee = fm_reward_lee(a, event, b, S.A, p);
info.event = event;  info.delivered = delivered;  info.expired = expired;
info.arrived = arrived;  info.overflow = overflow;  info.queue_len = numel(S.tier);
end
