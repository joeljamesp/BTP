function [net, ep_reward, trace] = fm_dqn_train_c(p, kind, episodes, opts)
h = opts.h;  lr0 = opts.lr;  lr_end = opts.lr_final;  bs = opts.batch;  bufN = opts.buffer;
nin = 11;  T = p.T;  lam = opts.lam0;  mss = opts.target;  trace = zeros(0, 3);
net = dqn_init_n(nin, h, h, opts.seed);  target = net;  rng(opts.seed + 1000);
B.X = zeros(nin, bufN);  B.A = zeros(1, bufN);  B.R = zeros(1, bufN);  B.Mu = zeros(1, bufN);  B.Xn = zeros(nin, bufN);
idx = 0;  cnt = 0;  ep_reward = zeros(episodes, 1);
decay = max(1, round(opts.eps_frac * episodes));  freeze_from = round((1 - opts.freeze_frac) * episodes);
for ep = 1:episodes
    eps = max(opts.eps_end, 1 - (1 - opts.eps_end) * ep / decay);
    lr = lr0 + (lr_end - lr0) * (ep - 1) / max(1, episodes - 1);
    S = fm_init(p);  tot = 0;
    for t = 1:T
        x = fm_features(S, kind, p);
        if rand() < eps, a = randi([0 1]); else, [~, ai] = max(dqn_forward(net, x)); a = ai - 1; end
        [S, r, info] = fm_step(S, a, p);
        xn = fm_features(S, kind, p);
        idx = mod(idx, bufN) + 1;  B.X(:,idx) = x;  B.A(idx) = a;  B.R(idx) = r;  B.Mu(idx) = info.miss_unit;  B.Xn(:,idx) = xn;  cnt = min(cnt+1, bufN);
        tot = tot + r;
        if cnt >= bs
            j = randi(cnt, [1 bs]);
            y = opts.rscale * (B.R(j) - lam * B.Mu(j)) + p.gamma * max(dqn_forward(target, B.Xn(:,j)), [], 1);
            [Qp, cache] = dqn_forward(net, B.X(:,j));
            dQ = zeros(2, bs);
            for k = 1:bs, ai = B.A(j(k)) + 1;  dQ(ai,k) = Qp(ai,k) - y(k); end
            net = dqn_sgd_update(net, dqn_backward(net, cache, dQ), lr);
        end
    end
    ep_reward(ep) = tot;
    if mod(ep, opts.target_every) == 0, target = net; end
    if mod(ep, opts.upd) == 0 && ep <= freeze_from
        st = rng;
        pol = @(S, t) double(find(dqn_forward(net, fm_features(S, kind, p)) == max(dqn_forward(net, fm_features(S, kind, p))), 1) - 1);
        pe = p;  pe.eval_offset = 777000;  M = fm_eval(pol, pe, 10, T);  rng(st);
        mss = 0.5 * mss + 0.5 * M.hazards_missed;
        lam = min(opts.lam_max, max(opts.lam_min, lam * exp(opts.eta * (mss - opts.target))));
        trace(end+1, :) = [ep, lam, mss];
    end
end
end
