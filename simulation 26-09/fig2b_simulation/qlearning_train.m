function [Q, ep_rewards] = qlearning_train(p, episodes, T, alpha)

nStates = (p.D+1)*32;
Q = zeros(nStates, 2);
ep_rewards = zeros(episodes, 1);

eps_start = 1.0;
eps_end = 0.01;
eps_decay_episodes = max(1, min(episodes, 250));

for ep = 1:episodes
    epsilon = max(eps_end, eps_start - (eps_start-eps_end)*(ep/eps_decay_episodes));

    s = [0 0 0 0 0 0];
    total_r = 0;

    for t = 1:T
        idx = state_index(s, p);

        if rand() < epsilon
            a = randi([0 1]);
        else
            [~, ai] = max(Q(idx, :));
            a = ai - 1;
        end

        [s_next, r, ~] = step_environment(s, a, p);
        idx_next = state_index(s_next, p);
        best_next = max(Q(idx_next, :));

        Q(idx, a+1) = Q(idx, a+1) + alpha*(r + p.gamma*best_next - Q(idx, a+1));

        total_r = total_r + r;
        s = s_next;
    end

    ep_rewards(ep) = total_r;
end

end
