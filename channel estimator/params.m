function p = params()
% Full-model parameters. Values marked (paper) are stated in the iRDRC letter; the rest are our choices.

p.D = 10;                 % queue capacity (paper)
p.lambda_d = 1;           % mean packet arrivals per step (paper)
p.nu1 = 4;                % packets sent per step on a good channel (paper)
p.nu2 = 2;                % packets sent per step on a bad channel (paper)
p.pc = 0.1;               % chance the channel is bad (paper)

p.r_pkt = [2 1];          % reward per delivered packet: good, bad channel (paper's r1, r2, read per packet)
p.r3 = 50;                % penalty for a missed hazard (paper)
p.r4 = 5;                 % radar detection reward factor (paper)
p.r5 = 3;                 % radar bonus per unit of hazard uncertainty cleared (our novel reward)

p.p0_v = 0.005;  p.p1_v = 0.1;      % speed (paper)
p.p0_w = 0.005;  p.p1_w = 0.046;    % weather (paper)
p.p0_r = 0.01;   p.p1_r = 0.05;     % road (our choice, paper leaves open)
p.p0_m = 0.01;   p.p1_m = 0.05;     % moving object (our choice)
p.tau_r = 0.7;  p.tau_w = 0.8;  p.tau_v = 0.6;  p.tau_m = 0.7;   % chance each reading is favorable (our choice)

p.tier_probs = [0.5 0.3 0.2];   % share of arriving packets that are tier 1, 2, 3 (our choice)
p.dl_by_tier = [10 6 3];        % steps a packet may wait before expiring
p.pen_by_tier = [4 8 12];       % penalty when a packet expires

% Phase 2: hidden-state memory and sensing (our choices)
p.phi = 0.8;              % hazard readings: how strongly a reading carries over to the next step (0 = independent, as in the paper)
p.phi_c = 0.8;            % channel: same idea
p.sensor_err = 0.1;       % free hazard sensors: chance one reading is wrong
p.snr_mean = [1 0];       % channel measurement level when the channel is good, bad
p.snr_sigma = 0.45;       % channel measurement noise (a single measurement is right about 87% of the time)

% Phase 3
p.gamma = 0.9;            % discount (paper leaves it open)
p.novel_r5 = 3;  p.novel_pen = [4 8 12];   % our novel reward's extra terms, always used to SCORE every agent
p.T = 115;                % steps per episode
end
