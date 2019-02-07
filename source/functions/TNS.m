function [frameFout, TNScoeffs] = TNS(frameFin, frameType)
%TNS Implements Temporal Noise Shaping for one channel
%   [frameFout, TNScoeffs] = TNS(frameFin, frameType, P)
%   Returns the following values:
%    - frameFout: MDCT coefficients after TNS. Matrix of dimensions 128x8
%    if frameType == ESH, else 1024x1 vector.
%    - TNScoeffs: Quantized TNS coefficients matrix of size 4x8 for ESH,
%    else 4x1.
%   Accepts the following arguments:
%    - frameFin: MDCT coefficients before TNS. Matrix of dimensions 128x8
%    if frameType == ESH, else 1024x1 vector.
%    - frameType: Can take one of the following values:
%       - OLS for ONLY_LONG_SEQUENCE (1)
%       - LSS for LONG_START_SEQUENCE (2)
%       - ESH for EIGHT_SHORT_SEQUENCE (3)
%       - LPS for LONG_STOP_SEQUENCE (4)
    OLS = 1;
    LSS = 2;
    ESH = 3;
    LPS = 4;
    
    %Bark bands for non-ESH frames.
    bjl = [0;2;4;6;8;10;12;14;16;18;20;22;24;26;28;30;32;34;36;38;41;44;47;
           50;53;56;59;62;66;70;74;78;82;87;92;97;103;109;116;123;131;139;
           148;158;168;179;191;204;218;233;249;266;284;304;325;348;372;398;
           426;457;491;528;568;613;663;719;782;854;938;1024];
       
    %Bark bands for ESH frames
    bjs = [0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;19;21;23;25;27;29;
           31;34;37;40;43;46;50;54;58;63;68;74;80;87;95;104;114;126;128];
       
    %Decide wich barks to use with frameType.
    if frameType == ESH
        b = bjs;
        Sw = zeros(128, 1);
    else
        b = bjl;
        Sw = zeros(1024, 1);
    end
    
    % Compensate for extra value in barks
    Nb = size(b, 1) - 1; 
    
    
    %Initialize output variables
    frameFout = zeros(size(frameFin));
    TNScoeffs = zeros(4, size(frameFin, 2));
    
    %Apply TNS. (We don't completly understand the code)
    for i = 1:size(frameFin, 2);
        X = frameFin(:, i);
        P = @(j) sum(X((b(j) + 1):b(j+1)).^2); %Power of input frameF for one bark.
        for j = 1:Nb
            Sw((b(j) + 1):b(j+1)) = sqrt(P(j)); %
        end
        for k = (Nb+1):-1:1, Sw(k) = (Sw(k) + Sw(k+1))/2; end
        for k = 2:Nb, Sw(k) = (Sw(k) + Sw(k-1))/2; end
        Xw = X./Sw;
        Xw(isnan(Xw)) = 0;
        [a, ~] = lpc(Xw, 4);
        a(isnan(a)) = 0;
        r = roots(a);
        r(abs(r) >= 1) = 0.99*r(abs(r) >= 1)./abs(r(abs(r) >= 1));
        a = fix(10*poly(r))/10;
        a = a(2:end);
        a(a > 0.8) = 0.8;
        a(a < -0.7) = -0.7;
        TNScoeffs(:, i) = a(:);
        frameFout(:, i) = filter([1 a], 1, X);
    end
end

