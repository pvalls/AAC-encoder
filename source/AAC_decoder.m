function AAC_decoder(encoded_filename, output_filename)
%AAC_decoder Implements an Advanced Audio Coding (AAC) alike decoding.

%- output_filename: Name with .wav of output .wav file


%Load the data from the encoded audiofile in .mat format.
load(encoded_filename)

fs = 44100; %Sampling frequency of output file.
K = size(AACSeq, 1); %K is the number of frames contained in AACSeq.
N = (K + 1)*1024; %N is the sample length of the output file.
x = zeros(N, 2); %Initilize reconstructed signal x.


    %Frame types dictionary.
    NUL = 0;
    OLS = 1;
    LSS = 2;
    ESH = 3;
    LPS = 4;
 
 % Load MPEG-4 standard huffman-coding books.
 huffLUT = loadLUT();
 scalefactorsCodebookNum = 12;
 
  %Open Decoding wait bar window.
  wait = waitbar(0, 'Decoding Audio...');
  
  for k = 1:K
     
      if AACSeq(k).frameType == ESH, sfclen = 42*8;
      else sfclen = 69; end
      
      
      % Huffman-decode and inverse quantization in left channel
        sfc = decodeHuff(AACSeq(k).chl.sfc, scalefactorsCodebookNum, huffLUT);
        sfc = sfc(1:sfclen);  
        S = decodeHuff(AACSeq(k).chl.stream, AACSeq(k).chl.codebook, huffLUT);
        
        chl_frameF = iAACquantizer(S(:), sfc(:), AACSeq(k).chl.G, AACSeq(k).frameType);
        
        % Huffman-decode and inverse quantization in right channel
        sfc = decodeHuff(AACSeq(k).chr.sfc, scalefactorsCodebookNum, huffLUT);
        sfc = sfc(1:sfclen);  
        S = decodeHuff(AACSeq(k).chr.stream, AACSeq(k).chr.codebook, huffLUT);
        S = S(1:1024); 
        chr_frameF = iAACquantizer(S(:), sfc(:), AACSeq(k).chr.G, AACSeq(k).frameType);
        
        
        %Inverse Temporal Noise Shaping
        chl_frameF = iTNS(chl_frameF,AACSeq(k).frameType, AACSeq(k).chl.TNScoeffs); 
        chr_frameF = iTNS(chr_frameF, AACSeq(k).frameType, AACSeq(k).chr.TNScoeffs);
        
        %Join two channels for applying Inverse FilterBanks.
        chl_frameF = chl_frameF(:);
        chr_frameF = chr_frameF(:);
        currFrameF = [chl_frameF chr_frameF];
        
         
        x(((k-1)*1024 + 1):(k+1)*1024, :) = x(((k-1)*1024 + 1):(k+1)*1024, :) ...
            + iFilterbank(currFrameF, AACSeq(k).frameType, AACSeq(k).winType);
        
       
        waitbar(k/K);
  end
  close(wait)
  
  %Delete first and last frame (that include part of the the initial zero
  %padding).
  x = x(1025:(N-1024), :);

  
   %Finally write the reconstructed audio file with specified name and format.
   audiowrite(output_filename, x, fs);
end 
    
   

