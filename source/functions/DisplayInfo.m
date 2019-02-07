function DisplayInfo(input_filename, encoded_filename, output_filename)
    
    %Add .mat extension to encoded file name.
    encoded_filename = strcat(encoded_filename, '.mat');
    
    %Read Files
    [y, fs] = audioread(input_filename);
    [x] = audioread(output_filename);

     N = min(size(y, 1), size(x, 1)); %N is the minimum number of samples of encoded/decoded file.
     x = x(1:N, :); %Select only first N samples.
     y = y(1:N, :);

    %Compute Signal to noise ratio (SNR)
    SNR(1) = snr(y(:, 1), x(:, 1) - y(:, 1));
    SNR(2) = snr(y(:, 2), x(:, 2) - y(:, 2));

    %Compute sound duration to later use for bitrate calculation.
    duration = N/fs;
    
    %Use dir to get file sizes
    encodedfile_info = dir(encoded_filename);
    encoded_size = encodedfile_info.bytes/1024;
    encoded_bitrate = encoded_size/duration;
    
    inputfile_info = dir(output_filename);
    input_size = inputfile_info.bytes/1024;
    input_bitrate = input_size/duration;

    %Compute compression ratio
    compression = encoded_size/input_size*100;

    disp(['Channel 1 SNR: ' num2str(SNR(1)) ' dB']);
    disp(['Channel 2 SNR: ' num2str(SNR(2)) ' dB']);
    disp(['Uncompressed audio size: ' num2str(input_size/1024) ' MB'])
    disp(['Uncompressed audio bitrate: ' num2str(input_bitrate) ' KB/s'])
    disp(['Compressed .mat file size: ' num2str(encoded_size/1024) ' MB'])
    disp(['Compressed .mat file bitrate: ' num2str(encoded_bitrate) ' KB/s'])
    disp(['Compression ratio: ' num2str(100-compression) ' %.'])
    disp(['The encoded file is ' num2str(round(100/compression, 2)) ' times smaller than the original file.'])
    
    
end