clear; clc; rng(1);

p = params();

episodes = 2500;
T = 300;
smooth_win = 61;

fprintf('Training Q-learning (%d episodes x %d steps)...\n', episodes, T);
[~, r_ql] = qlearning_train(p, episodes, T, 0.1);

fprintf('Training DQN (%d episodes x %d steps)...\n', episodes, T);
opts.seed = 1;
[~, r_dqn] = dqn_train(p, episodes, T, opts);

r_ql_s = moving_average(r_ql, smooth_win);
r_dqn_s = moving_average(r_dqn, smooth_win);

figure;
plot(1:episodes, r_dqn_s, 'LineWidth', 1.5); hold on;
plot(1:episodes, r_ql_s, 'LineWidth', 1.5);
xlabel('Episode');
ylabel('Total reward');
title('Fig. 2(a) reproduction: Total reward vs. Episode');
legend('DQN', 'Q-learning', 'Location', 'southeast');
grid on;

saveas(gcf, 'fig2a_reward_vs_episode.jpeg');
fprintf('Saved fig2a_reward_vs_episode.jpeg\n');

fprintf('Final (last 100 episodes) mean total reward -- DQN: %.2f | Q-learning: %.2f\n', ...
    mean(r_dqn(end-99:end)), mean(r_ql(end-99:end)));
