function [WL, WR] = sinwin(N)
    nl = 0:(N/2-1);
    nr = (N/2:N-1);
    WL = sin(pi/N*(nl + 1/2));
    WR = sin(pi/N*(nr + 1/2));
    WL = WL(:);
    WR = WR(:);
end
