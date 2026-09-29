function [s_next, aux_next, r_t, info] = step_environment(s, aux, a_t, p)

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

P_event = state_event_probability(r, w, v, m, p);
event_occurred = rand() < P_event;
b = r + w + v + m;

u = aux.u;
u_next = min(u + p.u_growth, 1);
if a_t == 1
    u_next = u_next * p.u_decay;
end

served = (a_t == 0) && (d > 0);
dl_next = aux.dl - 1;
deadline_expired = (dl_next <= 0) && ~served;

if served || deadline_expired
    pri_next = p.pri_levels(randi(numel(p.pri_levels)));
    dl_next = p.dl_max;
else
    pri_next = aux.pri;
end

aux_next.u = u_next;
aux_next.pri = pri_next;
aux_next.dl = dl_next;

r_t = novel_reward_function(a_t, c, event_occurred, b, u, u_next, aux.pri, deadline_expired, p);

info.P_event = P_event;
info.event_occurred = event_occurred;
info.b = b;
info.deadline_expired = deadline_expired;
info.uncertainty = u_next;

end
