clear; clc;

T = 500;
policies = {'round-robin', 'always-comm', 'always-radar'};
n = numel(policies);

base_G = zeros(n,1); base_total = zeros(n,1);
novel_G = zeros(n,1); novel_total = zeros(n,1);
novel_misses = zeros(n,1); novel_uncertainty = zeros(n,1);
novel_events = zeros(n,1);

pb = base_params();
pn = params();

for k = 1:n
    policy = policies{k};

    rng(10 + k);
    s = [0 0 0 0 0 0];
    rewards = zeros(T,1);
    for t = 1:T
        switch policy
            case 'round-robin', a_t = mod(t,2);
            case 'always-comm',  a_t = 0;
            case 'always-radar', a_t = 1;
        end
        [s, r_t, ~] = base_step_environment(s, a_t, pb);
        rewards(t) = r_t;
    end
    base_total(k) = sum(rewards);
    base_G(k) = discounted_return(rewards, pb.gamma);

    rng(10 + k);
    s = [0 0 0 0 0 0];
    aux.u = 0; aux.pri = pn.pri_levels(randi(numel(pn.pri_levels))); aux.dl = pn.dl_max;
    rewards = zeros(T,1);
    u_trace = zeros(T,1);
    misses = false(T,1);
    events = false(T,1);
    for t = 1:T
        switch policy
            case 'round-robin', a_t = mod(t,2);
            case 'always-comm',  a_t = 0;
            case 'always-radar', a_t = 1;
        end
        [s, aux, r_t, info] = step_environment(s, aux, a_t, pn);
        rewards(t) = r_t;
        u_trace(t) = info.uncertainty;
        misses(t) = info.deadline_expired;
        events(t) = info.event_occurred;
    end
    novel_total(k) = sum(rewards);
    novel_G(k) = discounted_return(rewards, pn.gamma);
    novel_misses(k) = sum(misses);
    novel_uncertainty(k) = mean(u_trace);
    novel_events(k) = sum(events);
end

fprintf('%-12s | %12s %12s | %12s %12s | %10s %10s\n', ...
    'policy', 'base G', 'novel G', 'base total', 'novel total', 'dl misses', 'mean u');
for k = 1:n
    fprintf('%-12s | %12.2f %12.2f | %12.2f %12.2f | %10d %10.3f\n', ...
        policies{k}, base_G(k), novel_G(k), base_total(k), novel_total(k), novel_misses(k), novel_uncertainty(k));
end

figure;
bar([base_G novel_G]);
set(gca, 'XTickLabel', policies);
ylabel('discounted return G(\pi)');
legend('base paper reward', 'novel reward', 'Location', 'best');
title('Discounted return: base paper reward vs. novel reward');
grid on;
saveas(gcf, 'results/compare_discounted_return.jpeg');

figure;
bar([base_total novel_total]);
set(gca, 'XTickLabel', policies);
ylabel('total reward');
legend('base paper reward', 'novel reward', 'Location', 'best');
title('Total reward: base paper reward vs. novel reward');
grid on;
saveas(gcf, 'results/compare_total_reward.jpeg');

figure;
bar(novel_misses);
set(gca, 'XTickLabel', policies);
ylabel('deadline misses out of 500 steps');
title('Deadline misses per policy (novel reward only, base paper has no deadline model)');
grid on;
saveas(gcf, 'results/novel_deadline_misses.jpeg');

figure;
bar(novel_uncertainty);
set(gca, 'XTickLabel', policies);
ylabel('mean belief uncertainty u');
title('Mean belief uncertainty per policy (novel reward only, base paper has no belief state)');
grid on;
saveas(gcf, 'results/novel_uncertainty.jpeg');

figure('Position', [100 100 1000 800]);
subplot(2,2,1);
bar([base_G novel_G]);
set(gca, 'XTickLabel', policies);
ylabel('G(\pi)');
legend('base', 'novel', 'Location', 'best');
title('Discounted return');
grid on;

subplot(2,2,2);
bar([base_total novel_total]);
set(gca, 'XTickLabel', policies);
ylabel('total reward');
legend('base', 'novel', 'Location', 'best');
title('Total reward');
grid on;

subplot(2,2,3);
bar(novel_misses);
set(gca, 'XTickLabel', policies);
ylabel('deadline misses');
title('Deadline misses (novel only)');
grid on;

subplot(2,2,4);
bar(novel_uncertainty);
set(gca, 'XTickLabel', policies);
ylabel('mean uncertainty');
title('Belief uncertainty (novel only)');
grid on;

sgtitle('Novelty comparison: base paper reward vs. proposed dual-role/deadline-aware reward');
saveas(gcf, 'results/novelty_comparison_summary.jpeg');

fid = fopen('results/comparison_summary.txt', 'w');
fprintf(fid, '%-12s | %12s %12s | %12s %12s | %10s %10s\n', ...
    'policy', 'base G', 'novel G', 'base total', 'novel total', 'dl misses', 'mean u');
for k = 1:n
    fprintf(fid, '%-12s | %12.2f %12.2f | %12.2f %12.2f | %10d %10.3f\n', ...
        policies{k}, base_G(k), novel_G(k), base_total(k), novel_total(k), novel_misses(k), novel_uncertainty(k));
end
fclose(fid);

fprintf('\nSaved comparison charts and summary to results/\n');
