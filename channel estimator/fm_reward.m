function r = fm_reward(a, c, event, b, k, expired, u, u_next, p)
if a == 0
    if ~event
        r = p.r_pkt(c+1) * k;
    else
        r = -p.r3;
    end
else
    if event
        r = p.r4 * (b + 1);
    else
        r = 0;
    end
    r = r + p.r5 * (u - u_next);
end
r = r - sum(p.pen_by_tier .* expired);
end
