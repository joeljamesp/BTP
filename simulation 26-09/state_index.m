function idx = state_index(s, p)

d = s(1); c = s(2); r = s(3); w = s(4); v = s(5); m = s(6);
idx = d*32 + c*16 + r*8 + w*4 + v*2 + m + 1;

end
