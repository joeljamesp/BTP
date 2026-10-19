function tune_one(tag, cfg, seed, pv, episodes)
if nargin < 5, episodes = 4000; end
p = params();  p.sensor_err = 0.25;  p.p1_v = pv;
p.r5 = cfg.r5;  p.pen_by_tier = 4 * cfg.s * (1:3) .^ cfg.g;  p.r_pkt = [2 1] * cfg.c;  p.r4 = cfg.r4;
pe = p;  pe.r3 = 50;  pe.eval_offset = 31000;
p.r3 = 0;  p.lee_w_radar = 0;
opts = struct('h', 32, 'lr', 0.001, 'lr_final', 0.00002, 'batch', 128, 'buffer', 20000, 'seed', seed, 'rscale', 0.1, 'eps_end', 0.05, 'eps_frac', 0.7, ...
              'target_every', 20, 'target', 0.12, 'lam0', 150, 'eta', 4, 'upd', 50, 'lam_min', 0.3, 'lam_max', 3000, 'freeze_frac', 0.15);
tic;  [net, ~, ~] = fm_dqn_train_c(p, 'belief', episodes, opts);  tt = toc;
lo = -6;  hi = 6;  best = [];
for it = 1:10
    d = 0.5 * (lo + hi);
    pol = @(S, t) double(diff(dqn_forward(net, fm_features(S, 'belief', pe))) + d > 0);
    M = fm_eval(pol, pe, 200, pe.T);
    if isempty(best) || abs(M.hazards_missed - 0.12) < abs(best.M.hazards_missed - 0.12), best.M = M;  best.delta = d; end
    if M.hazards_missed > 0.12, lo = d; else, hi = d; end
    if abs(M.hazards_missed - 0.12) < 0.005, break; end
end
M = best.M;  delta = best.delta;  train_seconds = tt;
save(sprintf('tune_%s.mat', tag), 'cfg', 'seed', 'pv', 'M', 'delta', 'train_seconds');
fprintf('%s: missed %.3f | delivered %.3f | T1 %.2f T2 %.2f T3 %.2f | delta %.2f | cfg r5 %.2f s %.2f g %.2f c %.2f r4 %.2f | %.0fs\n', ...
    tag, M.hazards_missed, M.delivered, M.expired_t1, M.expired_t2, M.expired_t3, delta, cfg.r5, cfg.s, cfg.g, cfg.c, cfg.r4, tt);
end
