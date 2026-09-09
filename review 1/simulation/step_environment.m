function [s_next, r_t, info] = step_environment(s, a_t, p)

d = s(1); c = s(2); r = s(3); w = s(4); v = s(5); m = s(6);

if c == 0
    transmitted = p.nu1;
else
    transmitted = p.nu2;
end
if a_t == 1
    transmitted = 0;
end
arrivals = poissrnd(p.lambda_d);
d_next = min(max(d - transmitted, 0) + arrivals, p.D);

c_next = double(rand() < p.pc);

r_next = double(rand() < (1 - p.tau_r));
w_next = double(rand() < (1 - p.tau_w));
v_next = double(rand() < (1 - p.tau_v));
m_next = double(rand() < (1 - p.tau_m));

s_next = [d_next c_next r_next w_next v_next m_next];

P_event = event_probability(p);
event_occurred = rand() < P_event;
b = r + w + v + m;

r_t = reward_function(a_t, c, event_occurred, b, p);

info.P_event = P_event;
info.event_occurred = event_occurred;
info.b = b;

end
