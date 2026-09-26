function [throughput, missdet] = eval_qtable_metrics(Q, p, episodes, T)

transmitted_total = 0;
steps_total = 0;
events_total = 0;
missed_total = 0;

for ep = 1:episodes
    s = [0 0 0 0 0 0];
    for t = 1:T
        idx = state_index(s, p);
        [~, ai] = max(Q(idx, :));
        a = ai - 1;

        c = s(2);
        if a == 0
            if c == 0
                transmitted = p.nu1;
            else
                transmitted = p.nu2;
            end
        else
            transmitted = 0;
        end

        [s, ~, info] = step_environment(s, a, p);

        transmitted_total = transmitted_total + transmitted;
        steps_total = steps_total + 1;

        if info.event_occurred
            events_total = events_total + 1;
            if a == 0
                missed_total = missed_total + 1;
            end
        end
    end
end

throughput = transmitted_total / steps_total;
missdet = missed_total / events_total;

end
