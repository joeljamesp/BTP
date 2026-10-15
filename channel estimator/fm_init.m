function S = fm_init(p)
% Start: hidden values drawn from their long-run chances, empty queue, belief = long-run chances
% updated once with the first free sensor reading.
rho = fm_rho(p);
S.c = double(rand() < rho(1));
S.x = double(rand(1,4) < rho(2:5));
S.tier = zeros(1,0);  S.dl = zeros(1,0);
S.A = zeros(1,3);                           % age of information per tier (only used by the Lee et al. reward)
o = S.x;  flip = rand(1,4) < p.sensor_err;  o(flip) = 1 - o(flip);
S.pb = [rho(1), fm_sensor_update(rho(2:5), o, p.sensor_err)];
S.last_o = o;  S.last_chat = 0;           % what a naive agent would remember
end
