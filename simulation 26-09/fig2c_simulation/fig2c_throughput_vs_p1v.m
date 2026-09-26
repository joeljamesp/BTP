clear; clc; rng(1);

p1v_values = 0.1:0.1:1;
n = numel(p1v_values);

train_episodes = 800;
T = 220;
eval_episodes = 200;

thr_dqn = zeros(n, 1);
thr_ql = zeros(n, 1);
thr_rr = zeros(n, 1);

for i = 1:n
    p = params();
    p.p1_v = p1v_values(i);

    fprintf('p1_v = %.1f ... ', p.p1_v);

    [Q, ~] = qlearning_train(p, train_episodes, T, 0.02);
    thr_ql(i) = eval_qtable_metrics(Q, p, eval_episodes, T);

    opts = struct('seed', i);
    [net, ~] = dqn_train(p, train_episodes, T, opts);
    thr_dqn(i) = eval_dqn_metrics(net, p, eval_episodes, T);

    thr_rr(i) = roundrobin_metrics(p, eval_episodes, T);

    fprintf('DQN=%.3f  Q-learning=%.3f  Round-robin=%.3f\n', thr_dqn(i), thr_ql(i), thr_rr(i));
end

figure;
plot(p1v_values, thr_dqn, '-o', 'LineWidth', 1.5); hold on;
plot(p1v_values, thr_ql, '-s', 'LineWidth', 1.5);
plot(p1v_values, thr_rr, '-^', 'LineWidth', 1.5);
xlabel('p_1^v');
ylabel('Throughput (packets/time step)');
title('Fig. 2(c) reproduction: Throughput vs. p_1^v');
legend('DQN', 'Q-learning', 'Round-robin', 'Location', 'best');
grid on;

saveas(gcf, 'fig2c_throughput_vs_p1v.jpeg');
fprintf('Saved fig2c_throughput_vs_p1v.jpeg\n');
