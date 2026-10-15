function r = fm_reward(a, c, event, b, k, expired, u, u_next, p)
% Our novel reward, same structure as novel_reward_function.m:
%   the paper's five cases, plus a radar bonus for uncertainty cleared, minus a per-tier deadline penalty.
% k = packets delivered this step, expired = expired packets per tier.
% u = hazard uncertainty the car would carry into the next step WITHOUT a scan, u_next = what it actually carries.
% (Measured against not scanning, so a scan that teaches nothing, e.g. independent readings, earns exactly zero.)
if a == 0
    if ~event
        r = p.r_pkt(c+1) * k;               % reward per delivered packet (paper's r1, r2 read per packet)
    else
        r = -p.r3;                           % missed hazard: the dominant penalty
    end
else
    if event
        r = p.r4 * (b + 1);                  % radar found a hazard
    else
        r = 0;
    end
    r = r + p.r5 * (u - u_next);             % radar's second job: clearing uncertainty
end
r = r - sum(p.pen_by_tier .* expired);       % priority-tier deadline penalty
end
