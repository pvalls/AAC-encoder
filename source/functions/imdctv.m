function y = imdctv(x)
% IMDCTV Calculates the Modified Discrete Cosine Transform in a vectorized way
%   y = imdctv(x)
%
%   x: input signal (can be either a column or frame per column)
%   y: IMDCT of x
%
%   Fast ! ! !

% ------- imdctv.m -----------------------------------------
% Marios Athineos, marios@ee.columbia.edu
% http://www.ee.columbia.edu/~marios/
% Copyright (c) 2002 by Columbia University.
% All rights reserved.
% ----------------------------------------------------------

[flen,fnum] = size(x);
% Make column if it's a single row
if (flen==1)
    x = x(:);
    flen = fnum;
    fnum = 1;
end

% We need these for furmulas below
M  = flen;    % Number of coefficients
N  = 2*M;     % Length of window
N0 = (M+1)/2; % Used in the loop
N4 = N/4;     % Do we really need the division by N/4 ?

% Create the inverse transformation matrix
[k,n] = meshgrid(0:(M-1),0:(N-1));
T = cos(pi*(n+N0).*(k+0.5)/M);
clear k n;

% So the MDCT is simply !!!
y = T*x/N4;
end

