function [huffSec, huffCodebook] = encodeHuff(coeffSec, huffLUT, forcedCodebook)
% ENCODEHUFF Huffman encoder stage
%
%   [huffSec, huffCodebook] = encodeHuff(coeffSec, huffLUT) performs
%   huffman coding for quantised (integer) values of a section coeffSec; 
%   huffLUT are the Huffman look-up tables to be loaded using loadLUT.m
%   
%   It returns huffSec, a string of '1' and '0' corresponding to the
%   Huffman encoded stream, and huffCodebook, the number of the Huffman
%   codebook used (see page 147 in w2203tfa.pdf and pages 82-94 in
%   w2203tft.pdf).
%
%  [huffSec, huffCodebook] = encodeHuff(coeffSec, huffLUT, forcedCodebook)
%  forces the codebook forcedCodebook to be used.

    if nargin == 2
        [huffSec, huffCodebook] = encodeHuff1(coeffSec, huffLUT);
    else
        huffSec = huffLUTCode1(huffLUT{forcedCodebook}, coeffSec);
        huffCodebook = forcedCodebook;
    end

function  [huffSec,  huffCodebook]=encodeHuff1(coeffSec,huffLUT)
maxAbsVal=max(abs(coeffSec));
ESC=0;%escape sequence used?
switch(maxAbsVal)
    case 0
        huffCodebook=0;
        [huffSec]=huffLUTCode0();
    case 1
        huffCodebook=[1 2];
%         signedValues=1;
%         nTupleSize=4;
%         maxAbsCodeVal=1;
        [huffSec1]=huffLUTCode1(huffLUT{huffCodebook(1)}, coeffSec);
        [huffSec2]=huffLUTCode1(huffLUT{huffCodebook(2)}, coeffSec);
        if(length(huffSec1)<=length(huffSec2))
            huffSec=huffSec1;
            huffCodebook=huffCodebook(1);
        else
            huffSec=huffSec2;
            huffCodebook=huffCodebook(2);
        end
    case 2
        huffCodebook=[3 4];
%         signedValues=0;
%         nTupleSize=4;
%         maxAbsCodeVal=2;
        [huffSec1]=huffLUTCode1(huffLUT{huffCodebook(1)}, coeffSec);
        [huffSec2]=huffLUTCode1(huffLUT{huffCodebook(2)}, coeffSec);
        if(length(huffSec1)<=length(huffSec2))
            huffSec=huffSec1;
            huffCodebook=huffCodebook(1);
        else
            huffSec=huffSec2;
            huffCodebook=huffCodebook(2);
        end
    case {3,4}
        huffCodebook=[5 6];
        [huffSec1]=huffLUTCode1(huffLUT{huffCodebook(1)}, coeffSec);
        [huffSec2]=huffLUTCode1(huffLUT{huffCodebook(2)}, coeffSec);
        if(length(huffSec1)<=length(huffSec2))
            huffSec=huffSec1;
            huffCodebook=huffCodebook(1);
        else
            huffSec=huffSec2;
            huffCodebook=huffCodebook(2);
        end
    case {5,6,7}
        huffCodebook=[7 8];
        [huffSec1]=huffLUTCode1(huffLUT{huffCodebook(1)}, coeffSec);
        [huffSec2]=huffLUTCode1(huffLUT{huffCodebook(2)}, coeffSec);
        if(length(huffSec1)<=length(huffSec2))
            huffSec=huffSec1;
            huffCodebook=huffCodebook(1);
        else
            huffSec=huffSec2;
            huffCodebook=huffCodebook(2);
        end
    case {8,9,10,11,12}
        huffCodebook=[9 10];
        [huffSec1]=huffLUTCode1(huffLUT{huffCodebook(1)}, coeffSec);
        [huffSec2]=huffLUTCode1(huffLUT{huffCodebook(2)}, coeffSec);
        if(length(huffSec1)<=length(huffSec2))
            huffSec=huffSec1;
            huffCodebook=huffCodebook(1);
        else
            huffSec=huffSec2;
            huffCodebook=huffCodebook(2);
        end
    case {13,14,15}
        huffCodebook=11;
        [huffSec]=huffLUTCode1(huffLUT{huffCodebook(1)}, coeffSec);
    otherwise
        huffCodebook=11;
        [huffSec]=huffLUTCodeESC(huffLUT{huffCodebook(1)}, coeffSec);
end



function [huffSec]=huffLUTCode1(huffLUT, coeffSec)
    LUT=huffLUT.LUT;
    huffCodebook=huffLUT.codebook;
    nTupleSize=huffLUT.nTupleSize;
    maxAbsCodeVal=huffLUT.maxAbsCodeVal;
    signedValues=huffLUT.signedValues;    
    numTuples=ceil(length(coeffSec)/nTupleSize);
    if(signedValues)
        coeffSec=coeffSec+maxAbsCodeVal;
        base=2*maxAbsCodeVal+1;
    else
        base=maxAbsCodeVal+1;
    end
    coeffSecPad=zeros(1,numTuples*nTupleSize);
    coeffSecPad(1:length(coeffSec))=coeffSec;
    for i=1:numTuples
        nTuple=coeffSecPad((i-1)*nTupleSize+1:i*nTupleSize);
        huffIndex=abs(nTuple)*(base.^[nTupleSize-1:-1:0])';
        hexHuff=LUT(huffIndex+1,3);

        hexHuff=dec2hex(hexHuff);%Dec values were saved. Converting to hex
        huffSecLen=LUT(huffIndex+1,2);
        if(signedValues)
            huffSec{i}=dec2bin(hex2dec(hexHuff),huffSecLen);
        else
            huffSec{i}=[dec2bin(hex2dec(hexHuff),huffSecLen),strcat((num2str(nTuple'<0))')];%appending sign
        end
    end
    huffSec=strcat([huffSec{:}]);

function [huffSec]=huffLUTCode0()
    huffSec='';
    
function [huffSec]=huffLUTCodeESC(huffLUT, coeffSec)
    LUT=huffLUT.LUT;
    huffCodebook=huffLUT.codebook;
    nTupleSize=huffLUT.nTupleSize;
    maxAbsCodeVal=huffLUT.maxAbsCodeVal;
    signedValues=huffLUT.signedValues;    
    
    numTuples=ceil(length(coeffSec)/nTupleSize);
    base=maxAbsCodeVal+1;
    coeffSecPad=zeros(1,numTuples*nTupleSize);
    coeffSecPad(1:length(coeffSec))=coeffSec;
    
    nTupleOffset=zeros(1,nTupleSize);
    for i=1:numTuples
        nTuple=coeffSecPad((i-1)*nTupleSize+1:i*nTupleSize);   
        lnTuple=nTuple;
        lnTuple(lnTuple==0)=eps;
        N4=max([0 0; floor(log2(abs(lnTuple)))]);
        N=max([0 0 ; N4-4]);
        esc=abs(nTuple)>15;
        
        nTupleESC=nTuple;
        nTupleESC(esc)=sign(nTupleESC(esc))*16;%Just keep the sixteens here (nTupleESC). nTuple contains the actual values
        
        huffIndex=abs(nTupleESC)*(base.^[nTupleSize-1:-1:0])';
        hexHuff=LUT(huffIndex+1,3);
        hexHuff=dec2hex(hexHuff);%Dec values were saved. Converting to hex
        huffSecLen=LUT(huffIndex+1,2);
        
        %Adding sufficient ones to the prefix. If N<=0 empty string created
        escape_prefix1='';
        escape_prefix2='';
        escape_prefix1(1:N(1))='1';
        escape_prefix2(1:N(2))='1';
        
        
        %Calculating the escape words. Taking absolute values. Will add the
        %sign later on
        if esc(1)
            escape_separator1='0';
            escape_word1=dec2bin(abs(nTuple(1))-2^(N4(1)),N4(1));
        else
            escape_separator1='';
            escape_word1='';
        end
        if esc(2)
            escape_separator2='0';
            escape_word2=dec2bin(abs(nTuple(2))-2^(N4(2)),N4(2));
        else
            escape_separator2='';
            escape_word2='';
        end
        
        % escape_word1=dec2bin(abs(nTuple(1))-2^(N4(1)),N4(1));
        
        escSeq=[escape_prefix1, escape_separator1, escape_word1, escape_prefix2, escape_separator2, escape_word2];
        
        %adding the sign bits and the escape sequence
        huffSec{i}=[dec2bin(hex2dec(hexHuff),huffSecLen),strcat((num2str(nTuple'<0))'), escSeq];%appending sign
    end
    huffSec=strcat([huffSec{:}]);
