function avg_r = eval_dqn(net, p, episodes, T)

ep_totals = zeros(episodes, 1);

for ep = 1:episodes
    s = [0 0 0 0 0 0];
    total = 0;
    for t = 1:T
        x = encode_state(s, p);
        Q = dqn_forward(net, x);
        [~, ai] = max(Q);
        a = ai - 1;
        [s, r, ~] = step_environment(s, a, p);
        total = total + r;
    end
    ep_totals(ep) = total;
end

avg_r = mean(ep_totals);

end
