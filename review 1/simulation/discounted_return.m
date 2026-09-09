function G = discounted_return(rewards, gamma)

T = numel(rewards);
discounts = gamma .^ (0:T-1)';
G = sum(discounts .* rewards(:));

end
