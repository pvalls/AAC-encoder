function frameF = iAACquantizer(S, sfc, G, frameType)
%IAACQUANTIZER Implements the inverse Quantizer step for one channel.
%   frameF = iAACquantizer(S, sfc, G, frameType)
%   See help AACquantizer for details.
    OLS = 1;
    LSS = 2;
    ESH = 3;
    LPS = 4;
    
    load('TableB219.mat');
    
    if frameType == ESH
        wlow = B219b(:, 2);
        whigh = B219b(:, 3);
        width = B219b(:, 4);
        bval = B219b(:, 5);
        qsthr = B219b(:, 6);
    else
        wlow = B219a(:, 2);
        whigh = B219a(:, 3);
        width = B219a(:, 4);
        bval = B219a(:, 5);
        qsthr = B219a(:, 6);
    end
    
    Nb = size(wlow, 1);
    
    if frameType == ESH
        subframes = 8;
        freqs = 128;
        S = reshape(S, [freqs, subframes]);
        sfc = reshape(sfc, [42, 8]);
    else
        subframes = 1;
        freqs = 1024;
    end
    
    frameF = zeros(freqs, subframes);
    for i = 1:subframes
        for j = 2:size(sfc, 1)
            sfc(j, i) = sfc(j, i) + sfc(j-1, i);
        end
        a = G(i) - sfc(:, i);
        % a = sfc(:, i);
        for b = 1:Nb
            idx = (wlow(b)+1):(whigh(b)+1);
            frameF(idx, i) = sign(S(idx, i)) .* (abs(S(idx, i)).^(4/3)) .* 2.^(1/4 * a(b));              
        end
    end
end

