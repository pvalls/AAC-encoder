%% This main script runs an Implementation of an AAC alike codec in MATLAB.
%
% Final Work for Voice and Audio Encoding Systems, Audiovisual Systems Engineering.
% Univerisy Pompeu Fabra Barcelona, December 2017.
%
% Authors: Pol Valls, Sergi Solà. 
% 
% Improvement on the work of Donovan Fortsworth, Elias K and Giannis A.
% Original Source Code: https://searchcode.com/file/11693972/trunk/source_tree.txt
% 

clc; clear; close all;

%addpath to make available the codec's auxiliar functions found in a sub folder.
addpath('./functions/');

% Choose the filename of the audio file to encode. The input audio must be stereo (2 channels).
% For good compression ratio encode a lossles file (wav or flac).
input_filename = 'inputAudio_long.wav'; 

% Choose the desired name for the encoded audio file (It will have .mat extension)
encoded_filename = 'encodedAudio';

% Choose the filename of the decoded audio file. 
output_filename = 'decodedAudio.wav'; 

% Call to main encoder
AAC_encoder(input_filename, encoded_filename);

% Call to main decoder
AAC_decoder(encoded_filename, output_filename);

% Display Coding and Decoding Info:
DisplayInfo(input_filename, encoded_filename, output_filename)










