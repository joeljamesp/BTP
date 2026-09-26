clear; clc; rng(1);

p1v_values = 0.1:0.1:1;
n = numel(p1v_values);

train_episodes = 800;
T = 220;
eval_episodes = 200;

md_dqn = zeros(n, 1);
md_ql = zeros(n, 1);
md_rr = zeros(n, 1);

for i = 1:n
    p = params();
    p.p1_v = p1v_values(i);

    fprintf('p1_v = %.1f ... ', p.p1_v);

    [Q, ~] = qlearning_train(p, train_episodes, T, 0.02);
    [~, md_ql(i)] = eval_qtable_metrics(Q, p, eval_episodes, T);

    opts = struct('seed', i);
    [net, ~] = dqn_train(p, train_episodes, T, opts);
    [~, md_dqn(i)] = eval_dqn_metrics(net, p, eval_episodes, T);

    [~, md_rr(i)] = roundrobin_metrics(p, eval_episodes, T);

    fprintf('DQN=%.3f  Q-learning=%.3f  Round-robin=%.3f\n', md_dqn(i), md_ql(i), md_rr(i));
end

figure;
plot(p1v_values, md_dqn, '-o', 'LineWidth', 1.5); hold on;
plot(p1v_values, md_ql, '-s', 'LineWidth', 1.5);
plot(p1v_values, md_rr, '-^', 'LineWidth', 1.5);
xlabel('p_1^v');
ylabel('Miss detection probability');
title('Fig. 2(d) reproduction: Miss detection probability vs. p_1^v');
legend('DQN', 'Q-learning', 'Round-robin', 'Location', 'best');
grid on;

saveas(gcf, 'fig2d_missdetection_vs_p1v.jpeg');
fprintf('Saved fig2d_missdetection_vs_p1v.jpeg\n');
