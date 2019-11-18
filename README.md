# AAC-encoder

Implementation of a simple [AAC](https://en.wikipedia.org/wiki/Advanced_Audio_Coding)-like Coder (Encoder + Decoder) in [MATLAB](https://en.wikipedia.org/wiki/MATLAB). 

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
## Project images

<a href="https://github.com/pvalls/AAC-encoder/raw/master/project_media/Audio%20Codec%20Scheme.png"><img src="https://github.com/pvalls/AAC-encoder/raw/master/project_media/Audio%20Codec%20Scheme.png" title="Audio CODEC Scheme" alt="Audio CODEC Scheme" width="900"></a>
</a>
<a href="https://github.com/pvalls/AAC-encoder/raw/master/project_media/AAC%20Scheme.png"><img src="https://github.com/pvalls/AAC-encoder/raw/master/project_media/AAC%20Scheme.png" title="AAC Scheme" alt="AAC Scheme" width="900"></a>
</a>
<a href="https://raw.githubusercontent.com/pvalls/AAC-encoder/master/project_media/Original-vs-Compressed.png"><img src="https://raw.githubusercontent.com/pvalls/AAC-encoder/master/project_media/Original-vs-Compressed.png" title="Original-vs-Compressed" alt="Original-vs-Compressed" width="900"></a>
</a>


## Acknowledgments

Professor   ALFONSO ANTONIO PEREZ CARRILLO

Contributor SERGI SOLÀ CASAS

RAVI LAKKUNDI's [original work](https://es.mathworks.com/matlabcentral/fileexchange/26137-aac-encoder)

(See the explanatory *Report.pdf* file on the repository for more info)


