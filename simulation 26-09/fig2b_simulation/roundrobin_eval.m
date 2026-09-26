function ep_rewards = roundrobin_eval(p, episodes, T)

ep_rewards = zeros(episodes, 1);

for ep = 1:episodes
    s = [0 0 0 0 0 0];
    total_r = 0;
    for t = 1:T
        a = mod(t, 2);
        [s, r, ~] = step_environment(s, a, p);
        total_r = total_r + r;
    end
    ep_rewards(ep) = total_r;
end

end
