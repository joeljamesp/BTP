function [Q, cache] = dqn_forward(net, X)

Z1 = net.W1*X + net.b1;
A1 = max(Z1, 0);
Z2 = net.W2*A1 + net.b2;
A2 = max(Z2, 0);
Z3 = net.W3*A2 + net.b3;

Q = Z3;
cache.X = X; cache.Z1 = Z1; cache.A1 = A1; cache.Z2 = Z2; cache.A2 = A2;

end
