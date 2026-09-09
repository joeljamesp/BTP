function S = state_space(p)

d_vals = (0:p.D)';
bin_vals = [0 1]';

[D,C,R,W,V,M] = ndgrid(d_vals, bin_vals, bin_vals, bin_vals, bin_vals, bin_vals);
S = [D(:) C(:) R(:) W(:) V(:) M(:)];

end
