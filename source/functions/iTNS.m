function frameFout = iTNS(frameFin, frameType, TNScoeffs)
%ITNS Implements inverse Temporal Noise Shaping for one channel
    frameFout = zeros(size(frameFin));
    for i = 1:size(frameFin, 2);
        X = frameFin(:, i);
        frameFout(:, i) = filter(1, [1; TNScoeffs(:, i)], X);
    end
end

