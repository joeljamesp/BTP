clear; clc;
rng(1);

p = params();

S = state_space(p);
fprintf('State space size: %d (expected %d)\n', size(S,1), (p.D+1)*2^5);

P_event = event_probability(p);
fprintf('P(unexpected event), marginal form: %.4f\n\n', P_event);

T = 500;
policies = {'round-robin', 'always-comm', 'always-radar'};
G_values = zeros(numel(policies), 1);

for k = 1:numel(policies)
    policy = policies{k};
    s = [0 0 0 0 0 0];
    aux.u = 0; aux.pri = p.pri_levels(randi(numel(p.pri_levels))); aux.dl = p.dl_max;
    rewards = zeros(T,1);
    d_trace = zeros(T,1);
    u_trace = zeros(T,1);
    events = false(T,1);
    misses = false(T,1);

    for t = 1:T
        switch policy
            case 'round-robin', a_t = mod(t,2);
            case 'always-comm',  a_t = 0;
            case 'always-radar', a_t = 1;
        end
        [s, aux, r_t, info] = step_environment(s, aux, a_t, p);
        rewards(t) = r_t;
        d_trace(t) = s(1);
        u_trace(t) = info.uncertainty;
        events(t) = info.event_occurred;
        misses(t) = info.deadline_expired;
    end

    G = discounted_return(rewards, p.gamma);
    G_values(k) = G;
    fprintf('[%-12s] total reward = %8.2f | discounted return G = %8.2f | mean queue d = %5.2f | mean uncertainty = %5.3f | events = %d/%d | deadline misses = %d/%d\n', ...
        policy, sum(rewards), G, mean(d_trace), mean(u_trace), sum(events), T, sum(misses), T);
end

figure;
bar(G_values);
set(gca, 'XTickLabel', policies);
ylabel('discounted return G(\pi)');
title('Baseline policy comparison, novel reward function');

s = [0 0 0 0 0 0];
aux.u = 0; aux.pri = p.pri_levels(randi(numel(p.pri_levels))); aux.dl = p.dl_max;
rewards = zeros(T,1);
d_trace = zeros(T,1);
u_trace = zeros(T,1);
for t = 1:T
    a_t = mod(t,2);
    [s, aux, r_t, ~] = step_environment(s, aux, a_t, p);
    rewards(t) = r_t;
    d_trace(t) = s(1);
    u_trace(t) = aux.u;
end

figure;
subplot(3,1,1);
plot(rewards); xlabel('time step'); ylabel('r_t'); title('Immediate reward (round-robin, novel reward)');
subplot(3,1,2);
plot(d_trace); xlabel('time step'); ylabel('d'); title('Queue length (round-robin)');
subplot(3,1,3);
plot(u_trace); xlabel('time step'); ylabel('u'); title('Belief uncertainty (round-robin)');

saveas(gcf, 'novel_reward_traces.jpeg');
