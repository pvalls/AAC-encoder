function frameF = filterbank(frameT, frameType, winType)
%FILTERBANK Implements filterbank step.
%   frameF = filterbank(frameT, frameType, winType)
%   Returns the following values:
%    - frameF: Frame representation in the frequency domain, using MDCT
%   coefficients. Matrix of size 1024x2 which either contains the two
%   channels coefficients, when the frame is OLS, LSS or LPS, either eight
%   submatrices of size 128x2, one for each subframe when the frame is ESH,
%   aligned in columns according to the subframes order.
%   Accepts the following arguments:
%    - frameT: Current frame's time domain representation.
%    - frameType: Current frame's chosen encoding type.
%    - winType: Current frame weight window's type. Can be either KBD(5)or
%    SIN(6).

    %Frame types dictionary.
    OLS = 1;
    LSS = 2;
    ESH = 3;
    LPS = 4;
    frameF = zeros(1024, 2);
    
    %For each frameType apply different window.
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
    
    %Compute Modified Discrete Cosine Transform of windowed frames.
    for i = 1:2
        if frameType == ESH
            for k = 1:8
                indT = 448 + (((k-1)*128+1):((k+1)*128));
                indF = ((k-1)*128+1):(k*128);
                frameF(indF, i) = mdctv(W.*frameT(indT, i));
            end
        else
            frameF(:, i) = mdctv(W.*frameT(:, i));
        end
    end
end

%Recursive function to generate the necessary window.
function [WL, WR] = win(N, winType, alpha)
    KBD = 5;
    SIN = 6;
    if winType == KBD
        [WL, WR] = kbdwin(N, alpha);
    else
        [WL, WR] = sinwin(N);
    end
end
