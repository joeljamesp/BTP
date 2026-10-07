function p = params()

p.D = 10;
p.lambda_d = 1;
p.nu1 = 4;
p.nu2 = 2;

p.pc = 0.1;

p.r1 = 2;
p.r2 = 1;
p.r3 = 50;
p.r4 = 5;

p.gamma = 0.99;

p.p0_v = 0.005;  p.p1_v = 0.1;
p.p0_w = 0.005;  p.p1_w = 0.046;

p.p0_r = 0.01;   p.p1_r = 0.05;
p.p0_m = 0.01;   p.p1_m = 0.05;

p.tau_r = 0.7;
p.tau_w = 0.8;
p.tau_v = 0.6;
p.tau_m = 0.7;

p.r5 = 3;
p.u_growth = 0.08;
p.u_decay = 0.5;

p.pri_levels = [1 2 3];
p.dl_by_pri  = [10 6 3];
p.pen_by_pri = [4 8 12];

end
