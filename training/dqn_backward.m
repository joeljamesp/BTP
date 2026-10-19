function grads = dqn_backward(net, cache, dQ)

N = size(dQ, 2);

dW3 = (dQ*cache.A2') / N;
db3 = mean(dQ, 2);

dA2 = net.W3' * dQ;
dZ2 = dA2 .* (cache.Z2 > 0);
dW2 = (dZ2*cache.A1') / N;
db2 = mean(dZ2, 2);

dA1 = net.W2' * dZ2;
dZ1 = dA1 .* (cache.Z1 > 0);
dW1 = (dZ1*cache.X') / N;
db1 = mean(dZ1, 2);

grads.W1 = dW1; grads.b1 = db1;
grads.W2 = dW2; grads.b2 = db2;
grads.W3 = dW3; grads.b3 = db3;

end
