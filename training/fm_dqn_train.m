function [net, ep_reward] = fm_dqn_train(p, kind, episodes, opts)
h = opts.h;  lr0 = opts.lr;  lr_end = opts.lr_final;  bs = opts.batch;  bufN = opts.buffer;
nin = 11;  T = p.T;
net = dqn_init_n(nin, h, h, opts.seed);  target = net;  rng(opts.seed + 1000);
B.X = zeros(nin, bufN);  B.A = zeros(1, bufN);  B.R = zeros(1, bufN);  B.Xn = zeros(nin, bufN);
idx = 0;  cnt = 0;  ep_reward = zeros(episodes, 1);
decay = max(1, round(opts.eps_frac * episodes));
for ep = 1:episodes
    eps = max(opts.eps_end, 1 - (1 - opts.eps_end) * ep / decay);
    lr = lr0 + (lr_end - lr0) * (ep - 1) / max(1, episodes - 1);
    S = fm_init(p);  tot = 0;
    for t = 1:T
        x = fm_features(S, kind, p);
        if rand() < eps, a = randi([0 1]); else, [~, ai] = max(dqn_forward(net, x)); a = ai - 1; end
        [S, r, ~] = fm_step(S, a, p);
        xn = fm_features(S, kind, p);
        idx = mod(idx, bufN) + 1;  B.X(:,idx) = x;  B.A(idx) = a;  B.R(idx) = r;  B.Xn(:,idx) = xn;  cnt = min(cnt+1, bufN);
        tot = tot + r;
        if cnt >= bs
            j = randi(cnt, [1 bs]);
            y = opts.rscale * B.R(j) + p.gamma * max(dqn_forward(target, B.Xn(:,j)), [], 1);
            [Qp, cache] = dqn_forward(net, B.X(:,j));
            dQ = zeros(2, bs);
            for k = 1:bs, ai = B.A(j(k)) + 1;  dQ(ai,k) = Qp(ai,k) - y(k); end
            net = dqn_sgd_update(net, dqn_backward(net, cache, dQ), lr);
        end
    end
    ep_reward(ep) = tot;
    if mod(ep, opts.target_every) == 0, target = net; end
end
end
