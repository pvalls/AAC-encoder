function SMR = psycho(frameT, frameType, frameTprev1, frameTprev2)
%SSC Implements Psychoacoustic model step (for one channel)
%   SMR = psycho(frameT, frameType, frameTprev1, frameTprev2)
%   Returns the following values:
%    - SMR: Signal to Mask Ratio, 42x8 matrix if frameType == ESH, else
%    69x1 vector.
%   Accepts the following arguments:
%    - frameT: Current frame's temporal representation (1 channel). 256x8
%    if frameType == ESH, else 2048x1
%    - frameType: Same as before.
%    - frameTprev1: Previous frame (1 channel).
%    - frameTprev2: Twice previous frame (1 channel).

    %Frame types dictionary.
    OLS = 1;
    LSS = 2;
    ESH = 3;
    LPS = 4;
    
    %Load data about the masking spread functions and Bands info table
    load('spread.mat');
    load('TableB219.mat');
    
    if frameType == ESH
        wlow = B219b(:, 2);
        whigh = B219b(:, 3);
        width = B219b(:, 4);
        bval = B219b(:, 5);
        qsthr = B219b(:, 6);
        spread = spreads;
        idxMF = 1:128;
    else
        wlow = B219a(:, 2);
        whigh = B219a(:, 3);
        width = B219a(:, 4);
        bval = B219a(:, 5);
        qsthr = B219a(:, 6);
        spread = spreadl;
        idxMF = 1:1024;
    end
    Nb = size(wlow, 1);

    %create frameM with previous + current frame.
    if frameType == ESH
        frameM = zeros(256, 10);
        frameM(:, 1) = frameTprev1(1217:1472);
        frameM(:, 2) = frameTprev1(1345:1600);
        for k = 1:8, frameM(:, k+2) = frameT(448 + (((k-1)*128+1):((k+1)*128))); end
    else
        frameM = [frameTprev2(:) frameTprev1(:) frameT(:)];
    end
    N = size(frameM, 1);
    n = 1:N;
    
    hannwin = 0.5 - 0.5*cos(pi/N*(n-0.5)); %Hanning window
    frameMF = fft(bsxfun(@times, frameM, hannwin')); %fast fourier tranform of frameM.
    r = abs(frameMF(idxMF, :)); %Separate magnitude and angle of DFT.
    f = angle(frameMF(idxMF, :));
    r_pred = zeros(size(r, 1), size(r, 2) - 2);
    f_pred = zeros(size(r_pred));
    for k = 3:size(r, 2)
        r_pred(:, k-2) = 2*r(:, k-1) - r(:, k-2);
        f_pred(:, k-2) = 2*f(:, k-1) - f(:, k-2);
    end
    r = r(:, 3:end);
    f = f(:, 3:end);
    c = sqrt((r.*cos(f) - r_pred.*cos(f_pred)).^2 ...
        + (r.*sin(f) - r_pred.*sin(f_pred)).^2)./(r + abs(r_pred));
    ef = @(b) sum(r((wlow(b)+1):(whigh(b)+1), :).^2);
    cf = @(b) sum(c((wlow(b)+1):(whigh(b)+1), :).*r((wlow(b)+1):(whigh(b)+1), :).^2);
    eb = zeros(Nb, size(r, 2));
    cb = zeros(Nb, size(r, 2));
    for bb = 1:Nb
        eb(bb, :) = ef(bb);
        cb(bb, :) = cf(bb);
    end
    ecb = (eb' * spread)';
    ctb = (cb' * spread)';
    cb = ctb ./ ecb;
    en = bsxfun(@rdivide, ecb, (sum(spread))');
    tb = -0.299 - 0.43 * log(cb);
    SNR = tb * 18 + (1 - tb) * 6;
    bc = 10 .^ (-SNR/10);
    nb = en .* bc;
    qthr_hat = eps * N / 2 * 10.^(qsthr/10);
    npart = bsxfun(@max, nb, qthr_hat);
    SMR = eb ./ npart;
end
