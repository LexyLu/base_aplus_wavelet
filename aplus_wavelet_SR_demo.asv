clear all;
close all;
clc;

current_path = pwd;
addpath(fullfile(current_path, '/methods'));  % the upscaling methods
addpath(fullfile(current_path, '/ksvdbox')) % K-SVD dictionary training algorithm
addpath(fullfile(current_path, '/ompbox')) % Orthogonal Matching Pursuit algorithm

wavelet_flag = {'LL','LH','HL','HH'};
wavelet_scale = 2; % scale of wavelet transform

upscaling = 2;
input_dir = 'Set5'; % Directory with input images from Set5 image dataset
pattern = '*.bmp'; % Pattern to process
dict_sizes = 1024;
    
mat_file = ['conf_zou_wavelet_' num2str(dict_sizes) '_x' num2str(upscaling)];
if exist([mat_file '.mat'],'file')
    disp(['Load trained dictionary...' mat_file]);
    load(mat_file, 'conf');
else
    [imgsWave, imgs, imgsCB, imgsCR] = load_images(glob('CVPR08-SR/Data/Training', '*.bmp'), wavelet_scale);
    for j=1:4
        disp(['Training dictionary of size ' num2str(dict_sizes) ' using Zeyde approach in wavelet area ' wavelet_flag{j} ' ...']);
        % Simulation settings
        conf.scale = upscaling; % scale-up factor
        conf.level = 1; % # of scale-ups to perform
        conf.window = [3 3]; % low-res. window size
        conf.border = [1 1]; % border of the image (to ignore)

        conf.overlap = [1 1]; % partial overlap (for faster training)
        if upscaling <= 2
            conf.overlap = [1 1]; % partial overlap (for faster training)
        end
        
        
    end
end