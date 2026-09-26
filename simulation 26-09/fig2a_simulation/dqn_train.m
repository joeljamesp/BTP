function [net, ep_rewards] = dqn_train(p, episodes, T, opts)

if nargin < 4, opts = struct(); end
h1 = getfield_default(opts, 'h1', 24);
h2 = getfield_default(opts, 'h2', 24);
lr = getfield_default(opts, 'lr', 0.001);
buffer_size = getfield_default(opts, 'buffer_size', 5000);
batch_size = getfield_default(opts, 'batch_size', 32);
target_update_every = getfield_default(opts, 'target_update_every', 20);
seed = getfield_default(opts, 'seed', 0);

net = dqn_init(h1, h2, seed);
target_net = net;

buf.X = zeros(6, buffer_size);
buf.A = zeros(1, buffer_size);
buf.R = zeros(1, buffer_size);
buf.Xn = zeros(6, buffer_size);
bufIdx = 0;
bufCount = 0;

ep_rewards = zeros(episodes, 1);

eps_start = 1.0;
eps_end = 0.01;
eps_decay_episodes = max(1, min(episodes, 150));

for ep = 1:episodes
    epsilon = max(eps_end, eps_start - (eps_start-eps_end)*(ep/eps_decay_episodes));

    s = [0 0 0 0 0 0];
    total_r = 0;

    for t = 1:T
        x = encode_state(s, p);

        if rand() < epsilon
            a = randi([0 1]);
        else
            Q = dqn_forward(net, x);
            [~, ai] = max(Q);
            a = ai - 1;
        end

        [s_next, r, ~] = step_environment(s, a, p);
        x_next = encode_state(s_next, p);

        bufIdx = mod(bufIdx, buffer_size) + 1;
        buf.X(:, bufIdx) = x;
        buf.A(bufIdx) = a;
        buf.R(bufIdx) = r;
        buf.Xn(:, bufIdx) = x_next;
        bufCount = min(bufCount+1, buffer_size);

        total_r = total_r + r;
        s = s_next;

        if bufCount >= batch_size
            idxs = randi(bufCount, [1 batch_size]);
            Xb = buf.X(:, idxs);
            Ab = buf.A(idxs);
            Rb = buf.R(idxs);
            Xnb = buf.Xn(:, idxs);

            Qnext = dqn_forward(target_net, Xnb);
            maxQnext = max(Qnext, [], 1);
            y = Rb + p.gamma .* maxQnext;

            [Qpred, cache] = dqn_forward(net, Xb);
            dQ = zeros(2, batch_size);
            for b = 1:batch_size
                ai = Ab(b) + 1;
                dQ(ai, b) = Qpred(ai, b) - y(b);
            end

            grads = dqn_backward(net, cache, dQ);
            net = dqn_sgd_update(net, grads, lr);
        end
    end

    ep_rewards(ep) = total_r;

    if mod(ep, target_update_every) == 0
        target_net = net;
    end
end

end

function v = getfield_default(s, name, default)
if isfield(s, name)
    v = s.(name);
else
    v = default;
end
end
