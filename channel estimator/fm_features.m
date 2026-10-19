function x = fm_features(S, kind, p)
switch kind
    case 'oracle', know = [S.c S.x];
    case 'belief', know = S.pb;
    case 'naive',  know = [S.last_chat S.last_o];
end
q = zeros(1,6);
for j = 1:3
    m = S.tier == j;
    q(j) = sum(m) / p.D;
    if any(m), q(3+j) = min(S.dl(m)) / p.dl_by_tier(j); else, q(3+j) = 1; end
end
x = [know, q]';
end
