function run_arm_c2(tag, kind, reward_mode, episodes, seed, ov, target, lam0, ck_every)
p = params();
if nargin > 5 && ~isempty(ov), for f = fieldnames(ov)', p.(f{1}) = ov.(f{1}); end, end
if strcmp(reward_mode, 'paper'), p.r5 = 0;  p.pen_by_tier = [0 0 0]; end
p.r3 = 0;  p.lee_w_radar = 0;
opts = struct('h', 32, 'lr', 0.001, 'lr_final', 0.00002, 'batch', 128, 'buffer', 20000, 'seed', seed, 'rscale', 0.1, 'eps_end', 0.05, 'eps_frac', 0.7, ...
              'target_every', 20, 'target', target, 'lam0', lam0, 'eta', 4, 'upd', 50, 'lam_min', 0.3, 'lam_max', 3000, 'freeze_frac', 0.15, 'ck', 100);
if nargin > 8, opts.ck = ck_every; end
[~, ~, trace, ck] = fm_dqn_train_c2(p, kind, episodes, opts);
save(sprintf('arm_ck2_%s.mat', tag), 'ck', 'trace', 'tag', 'kind', 'reward_mode', 'episodes');
fprintf('%s done: last checkpoint reward %.0f throughput %.2f missed %.3f\n', tag, ck(end,2), ck(end,3), ck(end,4));
end
