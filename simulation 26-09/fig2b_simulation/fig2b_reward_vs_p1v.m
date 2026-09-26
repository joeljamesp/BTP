clear; clc; rng(1);

p1v_values = 0.1:0.1:1;
n = numel(p1v_values);

train_episodes = 800;
T = 220;
eval_episodes = 30;

avg_r_dqn = zeros(n, 1);
avg_r_ql = zeros(n, 1);
avg_r_rr = zeros(n, 1);

for i = 1:n
    p = params();
    p.p1_v = p1v_values(i);

    fprintf('p1_v = %.1f ... ', p.p1_v);

    [Q, ~] = qlearning_train(p, train_episodes, T, 0.02);
    avg_r_ql(i) = eval_qtable(Q, p, eval_episodes, T);

    opts = struct('seed', i);
    [net, ~] = dqn_train(p, train_episodes, T, opts);
    avg_r_dqn(i) = eval_dqn(net, p, eval_episodes, T);

    rr_rewards = roundrobin_eval(p, eval_episodes, T);
    avg_r_rr(i) = mean(rr_rewards);

    fprintf('DQN=%.1f  Q-learning=%.1f  Round-robin=%.1f\n', avg_r_dqn(i), avg_r_ql(i), avg_r_rr(i));
end

figure;
plot(p1v_values, avg_r_dqn, '-o', 'LineWidth', 1.5); hold on;
plot(p1v_values, avg_r_ql, '-s', 'LineWidth', 1.5);
plot(p1v_values, avg_r_rr, '-^', 'LineWidth', 1.5);
xlabel('p_1^v');
ylabel('Average reward');
title('Fig. 2(b) reproduction: Average reward vs. p_1^v');
legend('DQN', 'Q-learning', 'Round-robin', 'Location', 'best');
grid on;

saveas(gcf, 'fig2b_reward_vs_p1v.jpeg');
fprintf('Saved fig2b_reward_vs_p1v.jpeg\n');
