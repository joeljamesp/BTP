function run_arm(tag, kind, reward_mode, episodes, seed, ov)
p = params();
if nargin > 5, for f = fieldnames(ov)', p.(f{1}) = ov.(f{1}); end, end
if strcmp(reward_mode, 'paper'), p.r5 = 0;  p.pen_by_tier = [0 0 0]; end
if strcmp(reward_mode, 'lee'),   p.reward_style = 'lee'; end
opts = struct('h', 32, 'lr', 0.001, 'lr_final', 0.00002, 'batch', 128, 'buffer', 20000, ...
              'seed', seed, 'rscale', 0.1 + 0.9 * strcmp(reward_mode, 'lee'), 'eps_end', 0.05, 'eps_frac', 0.7, 'target_every', 20);
tic;  [net, curve] = fm_dqn_train(p, kind, episodes, opts);  tt = toc;
pol = @(S, t) greedy(net, fm_features(S, kind, p));
M = fm_eval(pol, p, 300, p.T);
save(sprintf('arm_%s.mat', tag), 'M', 'curve', 'net', 'tag', 'kind', 'reward_mode', 'episodes');
fprintf('%s (%s features, %s reward, %d episodes, %.0fs): missed %.3f | delivered %.2f | expired T1 %.2f T2 %.2f T3 %.2f | radar %.2f | score paper %.1f novel %.1f\n', ...
    tag, kind, reward_mode, episodes, tt, M.hazards_missed, M.delivered, M.expired_t1, M.expired_t2, M.expired_t3, M.radar_share, M.score_paper, M.score_novel);
end
function a = greedy(net, x)
[~, i] = max(dqn_forward(net, x));  a = i - 1;
end
