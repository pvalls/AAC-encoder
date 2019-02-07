function AAC_encoder(input_filename, encoded_filename)

%AAC_encoder Implements an Advanced Audio Coding (AAC) alike encoding.
%
%AAC_encoder accepts the following arguments:
%    - input_filename: Name of input audio file to encode, with extension included.
%      Valid extensions:    WAVE (.wav)
%                           OGG (.ogg)
%                           FLAC (.flac)
%                           AU (.au)
%                           AIFF (.aiff, .aif)
%                           AIFC (.aifc)
%                           MP3 (.mp3)
%                           MPEG-4 AAC (.m4a, .mp4))

%    - encoded_filename: Name of output encoded audio file (with .mat extension)
% 
%   The final encoded file includes: 
%   Struct named AACSeq of Kx1 dimensions, where K is the number of encoded
%    frames. Every element has the following properties:
%        - AACSeq(i).frameType
%        - AACSeq(i).winType
%        - AACSeq(i).chl.TNScoeffs
%        - AACSeq(i).chr.TNScoeffs
%        - AACSeq(i).chl.T
%        - AACSeq(i).chr.T
%        - ACCSeq(i).chl.G
%        - ACCSeq(i).chr.G
%        - ACCSeq(i).chl.sfc
%        - ACCSeq(i).chr.sfc
%        - ACCSeq(i).chl.stream
%        - ACCSeq(i).chr.stream
%        - ACCSeq(i).chl.codebook
%        - ACCSeq(i).chr.codebook

    %Frame types dictionary.
    NUL = 0;
    OLS = 1;
    LSS = 2;
    ESH = 3;
    LPS = 4;
    
    %Window types dictionary
    KBD = 5;
    SIN = 6;
    
    prevFrameType = NUL;%First previous frame type will be NUL.
    defaultWinType = SIN;
    frameLength = 1024;
    
    %Read input audio file and save the signal amplitudes and sampling
    %frequency in variables y and fs.
    [y, fs] = audioread(input_filename);
    
    
    %Zero padd the signal to segment the audio in frames of exactly 1024 samples.
    trueN = size(y, 1);
    rightpad = 1024 - mod(trueN, frameLength);
    N = trueN + rightpad;
    y = [zeros(frameLength, 2); y; zeros(rightpad + frameLength*2, 2)];
    
    
    %We need a second more zero padded signal to be used when applying the psychoacoustic model.
    [y2, ~] = audioread(input_filename); 
    trueN = size(y2, 1);
    rightpad = 1024 - mod(trueN, frameLength);
    N = trueN + rightpad;
    y2 = [zeros(frameLength*3, 2); y2; zeros(rightpad + frameLength, 2)];
    K = size(y2, 1)/frameLength - 1;
    
   %Initialize struct variable. 
   AACSeq = struct('frameType', num2cell(zeros(K-2,1)), ...
                     'winType', num2cell(zeros(K-2,1)), ...
                     'chl', struct('TNScoeffs', 0, 'T', 0, 'G', 0, 'sfc', 0, 'stream', 0, 'codebook', 0), ...
                     'chr', struct('TNScoeffs', 0, 'T', 0, 'G', 0, 'sfc', 0, 'stream', 0, 'codebook', 0));
    
    
    % Load MPEG-4 standard huffman-coding books.
    % Codebooks are indexed from 1 to 12. 1-11 books are standard books for
    % encoding quantized spectrum stream. Book 12 is the standard book for encoding
    % quantization scalefactors
    huffLUT = loadLUT();
    scalefactorsCodebookNum = 12;
    
   %Open Encoding wait bar window.
   wait = waitbar(0, 'Encoding Audio...'); 
  
    for k = 1:(K-2)
        currFrameT = y(((k-1)*frameLength + 1):(k+1)*frameLength, :);  %Select current frame from signal.
        nextFrameT = y((k*frameLength + 1):(k+2)*frameLength, :);      %Select next frame from signal.
        frameType = SSC(currFrameT, nextFrameT, prevFrameType);        %Obtain frame type.
        prevFrameType = frameType;                                     %Assign previous frame type for next iteration.
        currframeF = filterbank(currFrameT, frameType, defaultWinType);%Apply Filterbanks.
        AACSeq(k).frameType = frameType;    
        AACSeq(k).winType = defaultWinType;
        
        %Separate current filtered frames in two channels.
        chl_frameF = currframeF(:, 1); 
        chr_frameF = currframeF(:, 2);
        
        %Here beggins what originally was the second level of complexity.
        if AACSeq(k).frameType == ESH, idx = reshape(1:1024, [128, 8]);
        else idx = 1:frameLength; end
       
       %Obtain Temporal Noise Shaping Coefficients and new frames filtered
       %by Linear Predictor Coefficients.
       [chl_frameF, AACSeq(k).chl.TNScoeffs] = TNS(chl_frameF(idx), AACSeq(k).frameType);
       [chr_frameF, AACSeq(k).chr.TNScoeffs] = TNS(chr_frameF(idx), AACSeq(k).frameType);
       
       % Use y2 and change frame lengts for the psychoacoustic model.
       frameT = y2(((k+1)*frameLength + 1):(k+3)*frameLength, :);
       frameTprev1 = y2(((k)*frameLength + 1):(k+2)*frameLength, :);
       frameTprev2 = y2(((k-1)*frameLength + 1):(k+1)*frameLength, :);
      
       
       % Calculate Signal to Mask Ratio (SMR) for using psychoacoustic model.
       % To be used latter in non homogenous quantization. Then Perfrom huffman encoding.
       
       %For left channel
       SMR = psycho(frameT(:, 1), frameType, frameTprev1(:, 1), frameTprev2(:, 1));
       [S, sfc, AACSeq(k).chl.G] = AACquantizer(chl_frameF, frameType, SMR);
       [AACSeq(k).chl.stream, AACSeq(k).chl.codebook] = encodeHuff(S(:), huffLUT);
       [AACSeq(k).chl.sfc, scalefactorsCodebookNum] = encodeHuff(sfc(:), huffLUT, scalefactorsCodebookNum);
        
       %For right/second channel
       SMR = psycho(frameT(:, 2), frameType, frameTprev1(:, 2), frameTprev2(:, 2));
       [S, sfc, AACSeq(k).chr.G] = AACquantizer(chr_frameF, frameType, SMR);
       [AACSeq(k).chr.stream, AACSeq(k).chr.codebook] = encodeHuff(S(:), huffLUT);
       [AACSeq(k).chr.sfc, scalefactorsCodebookNum] = encodeHuff(sfc(:), huffLUT, scalefactorsCodebookNum);
       
        waitbar(k/(K-2)); %Updaate Encoding wait bar status.
    end
    
    close(wait); %Close window of wait bar.
    
    %Save encoded Audio file with name "encoded_filename.mat". It saves the struct AACSeq.
    save(encoded_filename, 'AACSeq')
end
    

    
    
    
    
    
    
    
    
    
   
    
    
    
    

