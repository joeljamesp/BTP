function P = state_event_probability(r, w, v, m, p)

if r == 1
    pr = p.p1_r;
else
    pr = p.p0_r;
end

if w == 1
    pw = p.p1_w;
else
    pw = p.p0_w;
end

if v == 1
    pv = p.p1_v;
else
    pv = p.p0_v;
end

if m == 1
    pm = p.p1_m;
else
    pm = p.p0_m;
end

P = pr + pw + pv + pm;

end
