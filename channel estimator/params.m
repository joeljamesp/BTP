function p = params()

p.D = 10;
p.lambda_d = 1;
p.nu1 = 4;
p.nu2 = 2;
p.pc = 0.1;

p.r_pkt = [2 1];
p.r3 = 50;
p.r4 = 5;
p.r5 = 3;

p.p0_v = 0.005;  p.p1_v = 0.1;
p.p0_w = 0.005;  p.p1_w = 0.046;
p.p0_r = 0.01;   p.p1_r = 0.05;
p.p0_m = 0.01;   p.p1_m = 0.05;
p.tau_r = 0.7;  p.tau_w = 0.8;  p.tau_v = 0.6;  p.tau_m = 0.7;

p.tier_probs = [0.5 0.3 0.2];
p.dl_by_tier = [10 6 3];
p.pen_by_tier = [4 8 12];

p.phi = 0.8;
p.phi_c = 0.8;
p.sensor_err = 0.1;
p.snr_mean = [1 0];
p.snr_sigma = 0.45;

p.gamma = 0.9;
p.novel_r5 = 3;  p.novel_pen = [4 8 12];
p.T = 115;
end
