function y = moving_average(x, window)

x = x(:);
n = numel(x);
y = zeros(n, 1);
half = floor(window/2);

for i = 1:n
    lo = max(1, i-half);
    hi = min(n, i+half);
    y(i) = mean(x(lo:hi));
end

end
