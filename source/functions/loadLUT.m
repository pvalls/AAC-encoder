function huffLUT = loadLUT()
    load huffCodebooks
    load huffCodebookSF
    huffCodebooks{end + 1} = huffCodebookSF;
    for i=1:12
        h=huffCodebooks{i}(:,3);
        hlength=huffCodebooks{i}(:,2);
        for j=1:length(h)
            hbin{j}=dec2bin(h(j),hlength(j));
        end
        invTable{i}=vlcTable(hbin);
        clear hbin;
    end
    huffLUT{1}=struct('LUT',huffCodebooks{1},'invTable',invTable{1},'codebook',1,'nTupleSize',4,'maxAbsCodeVal',1,'signedValues',1);
    huffLUT{2}=struct('LUT',huffCodebooks{2},'invTable',invTable{2},'codebook',2,'nTupleSize',4,'maxAbsCodeVal',1,'signedValues',1);
    huffLUT{3}=struct('LUT',huffCodebooks{3},'invTable',invTable{3},'codebook',3,'nTupleSize',4,'maxAbsCodeVal',2,'signedValues',0);
    huffLUT{4}=struct('LUT',huffCodebooks{4},'invTable',invTable{4},'codebook',4,'nTupleSize',4,'maxAbsCodeVal',2,'signedValues',0);
    huffLUT{5}=struct('LUT',huffCodebooks{5},'invTable',invTable{5},'codebook',5,'nTupleSize',2,'maxAbsCodeVal',4,'signedValues',1);
    huffLUT{6}=struct('LUT',huffCodebooks{6},'invTable',invTable{6},'codebook',6,'nTupleSize',2,'maxAbsCodeVal',4,'signedValues',1);
    huffLUT{7}=struct('LUT',huffCodebooks{7},'invTable',invTable{7},'codebook',7,'nTupleSize',2,'maxAbsCodeVal',7,'signedValues',0);
    huffLUT{8}=struct('LUT',huffCodebooks{8},'invTable',invTable{8},'codebook',8,'nTupleSize',2,'maxAbsCodeVal',7,'signedValues',0);
    huffLUT{9}=struct('LUT',huffCodebooks{9},'invTable',invTable{9},'codebook',9,'nTupleSize',2,'maxAbsCodeVal',12,'signedValues',0);
    huffLUT{10}=struct('LUT',huffCodebooks{10},'invTable',invTable{10},'codebook',10,'nTupleSize',2,'maxAbsCodeVal',12,'signedValues',0);
    huffLUT{11}=struct('LUT',huffCodebooks{11},'invTable',invTable{11},'codebook',11,'nTupleSize',2,'maxAbsCodeVal',16,'signedValues',0);
    huffLUT{12}=struct('LUT',huffCodebooks{12},'invTable',invTable{12},'codebook',12,'nTupleSize',1,'maxAbsCodeVal',60,'signedValues',1);

function [h]=vlcTable(codeArray)
% Generates the inverse variable length coding tree, stored in a table. It
% is used for decoding.
% 
% codeArray: the input matrix, in the form of a cell array, with each cell 
% containing codewords represented in string format (array of chars) 
    h=zeros(1,3);
    for codeIndex=1:length(codeArray)
        word=str2num([codeArray{codeIndex}]')';
        hIndex=1;
        hLength=size(h,1);
        for i=1:length(word)
            k=word(i)+1;
            if(~h(hIndex,k))
                h(hIndex,k)=hLength+1;
                hIndex=hLength+1;
                h(hIndex,1:2)=zeros(1,2);
                hLength=hLength+1;
            else
                hIndex=h(hIndex,k);
            end
        end
        h(hIndex,3)=codeIndex;
    end