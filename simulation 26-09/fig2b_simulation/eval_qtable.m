function avg_r = eval_qtable(Q, p, episodes, T)

ep_totals = zeros(episodes, 1);

for ep = 1:episodes
    s = [0 0 0 0 0 0];
    total = 0;
    for t = 1:T
        idx = state_index(s, p);
        [~, ai] = max(Q(idx, :));
        a = ai - 1;
        [s, r, ~] = step_environment(s, a, p);
        total = total + r;
    end
    ep_totals(ep) = total;
end

avg_r = mean(ep_totals);

end
