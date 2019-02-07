function frameType = SSC(frameT, nextFrameT, prevFrameType)
%SSC Implements Sequence Segmentation Control step.
%   frameType = SSC(frameT, nextFrameT, prevFrameType)
%   Returns the following values:
%    - frameType: Can take one of the following values:
%       - OLS for ONLY_LONG_SEQUENCE (1)
%       - LSS for LONG_START_SEQUENCE (2)
%       - ESH for EIGHT_SHORT_SEQUENCE (3)
%       - LPS for LONG_STOP_SEQUENCE (4)
%   Accepts the following arguments:
%    - frameT: Frame i in the time domain. Contains 2 audio channels.
%    Matrix of size 2048x2. In the current implementation frameT is unused.
%    - nextFrameT: Next frame, with index i+1. Used for window selection.
%    Matrix of size 2048x2.
%    - prevFrameType: Type that was chosen for the previous frame, with
%    index i-1. Can also take the value NUL (0).
%
%   SSC.m Assigns a frame type to each frame depending on the type of the previous
%   frame and power distribution or next frame.
%

    %Frame types dictionary.
    NUL = 0;
    OLS = 1;
    LSS = 2;
    ESH = 3;
    LPS = 4;
    candidate = zeros(2,1);
    
    %For each channel we filter the next frame and obtain its power vector s.
    for ch = 1:2
        filtered = filter([0.7548, -0.7548], [1, -0.5095], nextFrameT(:, ch));
        s = sum(reshape(filtered(577:1600), [128, 8]).^2, 1)';
        ds = zeros(8, 1);
        for l = 2:8
            ds(l) = l*s(l)/sum(s(1:(l-1)));
        end
        
        %Rule based selection of frameType.
        isNextFrameESH = any((s > 1e-3) & (ds > 10));
        switch prevFrameType
            case OLS
                if (isNextFrameESH), candidate(ch) = LSS;
                else candidate(ch) = OLS;
                end
            case ESH
                if (isNextFrameESH), candidate(ch) = ESH;
                else candidate(ch) = LPS;
                end
            case LSS
                candidate(ch) = ESH;
            case LPS
                candidate(ch) = OLS;
            case NUL
                if (isNextFrameESH), candidate(ch) = ESH;
                else candidate(ch) = OLS;
                end
        end
    end
    if any(candidate == ESH)
        frameType = ESH;
    elseif any(candidate == LSS) && any(candidate == LPS)
        frameType = ESH;
    elseif any(candidate == LSS)
        frameType = LSS;
    elseif any(candidate == LPS)
        frameType = LPS;
    elseif candidate(1) == candidate(2)
        frameType = candidate(1);
    end
end
