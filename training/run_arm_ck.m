function run_arm_ck(tag, kind, reward_mode, episodes, seed, ov)
p = params();
if nargin > 5, for f = fieldnames(ov)', p.(f{1}) = ov.(f{1}); end, end
if strcmp(reward_mode, 'paper'), p.r5 = 0;  p.pen_by_tier = [0 0 0]; end
if strcmp(reward_mode, 'lee'),   p.reward_style = 'lee'; end
opts = struct('h', 32, 'lr', 0.001, 'lr_final', 0.00002, 'batch', 128, 'buffer', 20000, 'ck', 200, ...
              'seed', seed, 'rscale', 0.1 + 0.9 * strcmp(reward_mode, 'lee'), 'eps_end', 0.05, 'eps_frac', 0.7, 'target_every', 20);
[net, curve, ck] = fm_dqn_train_ck(p, kind, episodes, opts);
save(sprintf('arm_ck_%s.mat', tag), 'curve', 'ck', 'net', 'tag', 'kind', 'reward_mode', 'episodes');
fprintf('%s done: final checkpoint score paper %.1f novel %.1f missed %.3f delivered %.2f\n', tag, ck(end,2), ck(end,3), ck(end,4), ck(end,5));
end
