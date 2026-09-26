function net = dqn_init(h1, h2, seed)

rng(seed);

net.W1 = randn(h1, 6) * sqrt(2/6);
net.b1 = zeros(h1, 1);
net.W2 = randn(h2, h1) * sqrt(2/h1);
net.b2 = zeros(h2, 1);
net.W3 = randn(2, h2) * sqrt(2/h2);
net.b3 = zeros(2, 1);

end
