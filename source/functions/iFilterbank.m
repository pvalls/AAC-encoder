function frameT = iFilterbank(frameF, frameType, winType)
%FILTERBANK Implements inverse filterbank step. (see filterbank)
    OLS = 1;
    LSS = 2;
    ESH = 3;
    LPS = 4;
    frameT = zeros(2048, 2);
    switch frameType
        case OLS
            [WL, WR] = win(2048, winType, 6);
            W = [WL; WR];
        case LSS
            [WL, ~] = win(2048, winType, 6);
            [~, WR] = win(256, winType, 4);
            W = [WL; ones(448, 1); WR; zeros(448, 1)];
        case LPS
            [WL, ~] = win(256, winType, 4);
            [~, WR] = win(2048, winType, 6);
            W = [zeros(448, 1); WL; ones(448, 1); WR];
        case ESH
            [WL, WR] = win(256, winType, 4);
            W = [WL; WR];
    end
    for i = 1:2
        if frameType == ESH
            for k = 1:8
                indT = 448 + (((k-1)*128+1):((k+1)*128));
                indF = ((k-1)*128+1):(k*128);
                frameT(indT, i) = frameT(indT, i) + W.*imdctv(frameF(indF, i));
            end
        else
            frameT(:, i) = W.*imdctv(frameF(:, i));
        end
    end
end

function [WL, WR] = win(N, winType, alpha)
    KBD = 5;
    SIN = 6;
    if winType == KBD
        [WL, WR] = kbdwin(N, alpha);
    else
        [WL, WR] = sinwin(N);
    end
end

