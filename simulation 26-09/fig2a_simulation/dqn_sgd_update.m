function net = dqn_sgd_update(net, grads, lr)

net.W1 = net.W1 - lr*grads.W1;
net.b1 = net.b1 - lr*grads.b1;
net.W2 = net.W2 - lr*grads.W2;
net.b2 = net.b2 - lr*grads.b2;
net.W3 = net.W3 - lr*grads.W3;
net.b3 = net.b3 - lr*grads.b3;

end
