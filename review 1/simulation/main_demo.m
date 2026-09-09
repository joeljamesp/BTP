clear; clc;
rng(1);

p = params();

S = state_space(p);
fprintf('State space size: %d (expected %d)\n', size(S,1), (p.D+1)*2^5);

P_event = event_probability(p);
fprintf('P(unexpected event): %.4f\n\n', P_event);

T = 500;
policies = {'round-robin', 'always-comm', 'always-radar'};

for k = 1:numel(policies)
    policy = policies{k};
    s = [0 0 0 0 0 0];
    rewards = zeros(T,1);
    d_trace = zeros(T,1);
    events = false(T,1);

    for t = 1:T
        switch policy
            case 'round-robin', a_t = mod(t,2);
            case 'always-comm',  a_t = 0;
            case 'always-radar', a_t = 1;
        end
        [s, r_t, info] = step_environment(s, a_t, p);
        rewards(t) = r_t;
        d_trace(t) = s(1);
        events(t) = info.event_occurred;
    end

    G = discounted_return(rewards, p.gamma);
    fprintf('[%-12s] total reward = %8.2f | discounted return G = %8.2f | mean queue d = %5.2f | events = %d/%d\n', ...
        policy, sum(rewards), G, mean(d_trace), sum(events), T);
end

s = [0 0 0 0 0 0];
rewards = zeros(T,1);
d_trace = zeros(T,1);
for t = 1:T
    a_t = mod(t,2);
    [s, r_t, ~] = step_environment(s, a_t, p);
    rewards(t) = r_t;
    d_trace(t) = s(1);
end

figure;
subplot(2,1,1);
plot(rewards); xlabel('time step'); ylabel('r_t'); title('Immediate reward (round-robin policy)');
subplot(2,1,2);
plot(d_trace); xlabel('time step'); ylabel('d'); title('Queue length (round-robin policy)');
