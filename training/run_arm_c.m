function run_arm_c(tag, kind, reward_mode, episodes, seed, ov, target, lam0)
p = params();
if nargin > 5 && ~isempty(ov), for f = fieldnames(ov)', p.(f{1}) = ov.(f{1}); end, end
pe = p;  pe.r3 = 50;
if strcmp(reward_mode, 'paper'), p.r5 = 0;  p.pen_by_tier = [0 0 0]; end
if strcmp(reward_mode, 'lee'),   p.reward_style = 'lee'; end
p.r3 = 0;  p.lee_w_radar = 0;
opts = struct('h', 32, 'lr', 0.001, 'lr_final', 0.00002, 'batch', 128, 'buffer', 20000, 'seed', seed, ...
              'rscale', 0.1 + 0.9 * strcmp(reward_mode, 'lee'), 'eps_end', 0.05, 'eps_frac', 0.7, 'target_every', 20, ...
              'target', target, 'lam0', lam0, 'eta', 4, 'upd', 50, 'lam_min', 0.3, 'lam_max', 3000, 'freeze_frac', 0.15);
tic;  [net, curve, trace] = fm_dqn_train_c(p, kind, episodes, opts);  tt = toc;
pol = @(S, t) double(find(dqn_forward(net, fm_features(S, kind, pe)) == max(dqn_forward(net, fm_features(S, kind, pe))), 1) - 1);
M = fm_eval(pol, pe, 300, pe.T);
save(sprintf('arm_%s.mat', tag), 'M', 'curve', 'net', 'trace', 'tag', 'kind', 'reward_mode', 'episodes', 'target');
fprintf('%s (%s features, %s reward, target %.2f, %.0fs): missed %.3f | delivered %.2f | expired T1 %.2f T2 %.2f T3 %.2f | radar %.2f | final lambda %.1f | score paper %.1f ours %.1f\n', ...
    tag, kind, reward_mode, target, tt, M.hazards_missed, M.delivered, M.expired_t1, M.expired_t2, M.expired_t3, M.radar_share, trace(end,2), M.score_paper, M.score_novel);
end
