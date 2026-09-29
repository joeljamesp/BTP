function r_t = novel_reward_function(a_t, c, event_occurred, b, u, u_next, pri, deadline_expired, p)

if a_t == 0
    if ~event_occurred
        if c == 0
            r_t = p.r1;
        else
            r_t = p.r2;
        end
    else
        r_t = -p.r3;
    end
else
    if event_occurred
        r_t = p.r4 * (b + 1);
    else
        r_t = 0;
    end
    r_t = r_t + p.r5 * (u - u_next);
end

if deadline_expired
    r_t = r_t - p.r6 * pri;
end

end
