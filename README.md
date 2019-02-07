# AAC-encoder

Implementation of an Advance Audio Codec (AAC) Encoder/Decoder with [MATLAB](https://en.wikipedia.org/wiki/MATLAB). 

Final project for *Voice and Audio Encoding* subject at [Universitat Pompeu Fabra (Barcelona).](https://www.upf.edu)

## Function tree

```
|--main_AAC.m
             |--AAC_encoder.m
                             |--SSC.m
                             |--Filterbank.m
                                            |--mdctv.m
                                            |--sinwin.m/kbdwin.m

                             |--TNS.m 
                             |--psycho.m
                             |--AACquantizer.m
                             |--encodeHuff.m

             |--AAC_decoder.m
                             |--decodeHuff.m
                             |--iAACquantizer.m
                             |--iTNS.m
                             |--iFilterbank.m
                                             |--imdctv.m
                                             |--sinwin.m/kbdwin.m
             |--DisplayInfo.m
```

## Acknowledgments

Professor   ALFONSO ANTONIO PEREZ CARRILLO

Contributor SERGI SOLÀ CASAS

RAVI LAKKUNDI's [original work](https://es.mathworks.com/matlabcentral/fileexchange/26137-aac-encoder)

(See *pdf* file on repository for more info)


