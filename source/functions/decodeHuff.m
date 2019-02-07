function decCoeffs = decodeHuff(huffSec, huffCodebook, huffLUT)
% DECODEHUFF Huffman decoder stage
%
%   decCoeffs = decodeHuff(huffSec, huffCodebook, huffLUT) performs huffman
%   decoding, where huffSec is a string of '1' and '0' corresponding to the
%   Huffman encoded stream, and huffCodebook is the index (0 to 12) of the 
%   codebook used, as outputted by encodeHuff. huffLUT is the Huffman 
%   look-up tables to be loaded using loadLUT.m. The output decCoeffs is
%   the decoded quantised (integer) values.
%
%   CAUTION: due to zero padding the length of decCoeffs may be larger than
%   the length of the encoded sequence. Simply ignore values (they should
%   be equal to zero) that are outside the index range 
%   [1:length(encoded sequence)].

huffLUTi = huffLUT{huffCodebook};
h=huffLUTi.invTable;
huffCodebook=huffLUTi.codebook;
nTupleSize=huffLUTi.nTupleSize;
maxAbsCodeVal=huffLUTi.maxAbsCodeVal;
signedValues=huffLUTi.signedValues;
eos=0;%end of stream
decCoeffs=[];

huffSec=huffSec-48;
streamIndex=1;
while(~eos)%end of stream
    huffFailure=0;
    wordbit=0;
    r=1;%row indicator
    b=huffSec(streamIndex+wordbit);
  
    %decoding tuple according to inverse matrix
    while(1)
        b=huffSec(streamIndex+wordbit);
        wordbit=wordbit+1;
        rOld=r;
        r=h(rOld,b+1);%new index
        if((h(r,1)==0)&(h(r,2)==0))%reached a leaf (found a valid word)
            symbolIndex=h(r,3)-1;%The actual index begins from zero.
            streamIndex=streamIndex+wordbit;
            break;
        end
    end
    %decoding nTuple magnitudes
    if(signedValues)
        base=2*maxAbsCodeVal+1;
        nTupleDec=rem(floor(symbolIndex*base.^([-nTupleSize+1:1:0])),base);
        nTupleDec=nTupleDec-maxAbsCodeVal;
    else
        base=maxAbsCodeVal+1;
        nTupleDec=rem(floor(symbolIndex*base.^([-nTupleSize+1:1:0])),base);
        nTupleSignBits=huffSec(streamIndex:streamIndex+nTupleSize-1);
        nTupleSign=-sign(nTupleSignBits(:)'-0.5);
        streamIndex=streamIndex+nTupleSize;
        nTupleDec=nTupleDec.*nTupleSign;
    end
    escIndex=find(abs(nTupleDec)==16);
    if((huffCodebook==11)&&(sum(escIndex)))
        for i=1:length(escIndex)
            b=huffSec(streamIndex);
            N=0;
            %reading the escape seq, counting N '1's
            while(b)
                N=N+1;
                b=huffSec(streamIndex+N);
            end%last bit read was a zero corresponding to esc_separator..
            streamIndex=streamIndex+N;
            %reading the next N+4 bits
            N4=N+4;
            escape_word=huffSec(streamIndex+1:streamIndex+N4);
            nTupleDec(escIndex(i))=2^N4+bin2dec(num2str(escape_word));
            streamIndex=streamIndex+N4+1;
        end
        nTupleDec(escIndex)=nTupleDec(escIndex).*nTupleSign(escIndex);
    end
    decCoeffs=[decCoeffs nTupleDec];
    if (streamIndex>length(huffSec))
        eos=1;   
    end

end
