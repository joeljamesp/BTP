function x = fm_features(S, kind, p)
% Network input (column of 11 numbers between 0 and 1): what the car knows + what is waiting in the queue.
%   'oracle' : the true channel and hazard readings
%   'belief' : the Bayes-filter belief about them
%   'naive'  : the latest noisy hazard readings and latest channel measurement, trusted as if true
switch kind
    case 'oracle', know = [S.c S.x];
    case 'belief', know = S.pb;
    case 'naive',  know = [S.last_chat S.last_o];
end
q = zeros(1,6);
for j = 1:3
    m = S.tier == j;
    q(j) = sum(m) / p.D;                                   % how many tier-j packets wait
    if any(m), q(3+j) = min(S.dl(m)) / p.dl_by_tier(j); else, q(3+j) = 1; end   % how close the nearest one is to expiring
end
x = [know, q]';
end
