function [WL, WR] = kbdwin(N, alpha)
%[WL, WR] = kbdwin(N, alpha)
    psum = 0;
    WL = zeros(N/2, 1);
    w = kaiser(N/2 + 1, pi*alpha);
    for n = 1:(N/2)
        psum = psum + w(n);
        WL(n) = psum;
    end
    WL = sqrt(WL./sum(w));
    WR = WL(end:-1:1);
    WL = WL(:);
    WR = WR(:);
end
