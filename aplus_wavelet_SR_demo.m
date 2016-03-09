clear all;
close all;
clc;

current_path = pwd;
addpath(fullfile(current_path, '/methods'));  % the upscaling methods
addpath(fullfile(current_path, '/ksvdbox')) % K-SVD dictionary training algorithm
addpath(fullfile(current_path, '/ompbox')) % Orthogonal Matching Pursuit algorithm
addpath(fullfile(current_path, '/nlm_post_process')); % NLM post-process algorithm

wavelet_flag = {'LL','LH','HL','HH'};
wavelet_scale = 2; % scale of wavelet transform

upscaling =3;
crop_num = lcm(wavelet_scale,upscaling); % parameter used in function "modcrop"
input_dir = 'Set5'; % Directory with input images from Set5 image dataset
% input_dir = 'Set14'; % Directory with input images from Set14 image dataset
pattern = '*.bmp'; % Pattern to process
dict_sizes = 1024;
    
%% Training
mat_file = ['conf_zou_wavelet_' num2str(dict_sizes) '_x' num2str(upscaling)];
if exist([mat_file '.mat'],'file')
    disp(['Load trained dictionary...' mat_file]);
    load(mat_file, 'conf');
else
    [imgs, imgsCB, imgsCR] = load_images(glob('CVPR08-SR/Data/Training', '*.bmp'));
    disp(['Training dictionary of size ' num2str(dict_sizes) ' using Zeyde approach in wavelet area ...']);
    % Simulation settings
    conf.scale = upscaling; % scale-up factor
    conf.upsample_factor = upscaling; % upsample low-res. into mid-res.
    conf.level = 1; % # of scale-ups to perform
    conf.window = [3 3]; % low-res. window size
    conf.border = [1 1]; % border of the image (to ignore)
    conf.interpolate_kernel = 'bicubic';
    conf.filters = {};
    conf.wavelet_name = 'bior4.4';

    conf.overlap = [1 1]; % partial overlap (for faster training)
    if upscaling <= 2
        conf.overlap = [1 1]; % partial overlap (for faster training)
    end

    conf = learn_dict(conf, imgs, dict_sizes, wavelet_scale); 
    save(mat_file, 'conf');
end

%% Reconstruction

conf.filenames = glob(input_dir, pattern); % Cell array
res = cell(numel(conf.filenames),1);
res_nlm = cell(numel(conf.filenames),1);
res_RGB_my = cell(numel(conf.filenames),1);
res_RGB_my_NLM = cell(numel(conf.filenames),1);
res_PSNR = zeros(numel(conf.filenames),3);
[imgs_testGT,imgsCB_testGT,imgsCR_testGT] = load_images(conf.filenames);
for i=1:numel(conf.filenames)
    img = imgs_testGT{i};
    img = modcrop({img},crop_num);
    low = resize(img, 1/conf.scale^conf.level, conf.interpolate_kernel);
    interpolated = resize(low, conf.scale^conf.level, conf.interpolate_kernel);
    temp = scaleup_wavelet_zeyde( conf,low ); % aplus_wavelet_SR reconstruction
    res{i} = temp{1};
    
    res_nlm{i} = post_processing(res{i}, low{1},conf.upsample_factor, 0.05, 1.8);
    
    res_PSNR(i,1) = cal_PSNR( interpolated{1}(conf.window(1,1):end-conf.window(1,1)+1,conf.window(1,1):end-conf.window(1,1)+1),...
        img{1}(conf.window(1,1):end-conf.window(1,1)+1,conf.window(1,1):end-conf.window(1,1)+1));
    res_PSNR(i,2) = cal_PSNR( res{i}(conf.window(1,1):end-conf.window(1,1)+1,conf.window(1,1):end-conf.window(1,1)+1),...
        img{1}(conf.window(1,1):end-conf.window(1,1)+1,conf.window(1,1):end-conf.window(1,1)+1) );
    res_PSNR(i,3) = cal_PSNR( res_nlm{i}(conf.window(1,1):end-conf.window(1,1)+1,conf.window(1,1):end-conf.window(1,1)+1),...
        img{1}(conf.window(1,1):end-conf.window(1,1)+1,conf.window(1,1):end-conf.window(1,1)+1) );
end

if (~ exist(['.\',input_dir,'\results_my_x',num2str(conf.scale)],'dir'))
    mkdir(['.\',input_dir,'\results_my_x',num2str(conf.scale)]);
end
if (~ exist(['.\',input_dir,'\results_my_nlm_x',num2str(conf.scale)],'dir'))
    mkdir(['.\',input_dir,'\results_my_nlm_x',num2str(conf.scale)]);
end
for i=1:numel(conf.filenames)
    if (isempty(imgsCB_testGT{i}))
        res_RGB_my{i} = res{i};
        res_RGB_my_NLM{i} = res_nlm{i};
    else
        img_CB = imgsCB_testGT{i};
        img_CB = modcrop({img_CB},crop_num);
        low_CB = resize(img_CB, 1/conf.scale^conf.level, conf.interpolate_kernel);
        interpolated_CB = resize(low_CB, conf.scale^conf.level, conf.interpolate_kernel);

        img_CR = imgsCR_testGT{i};
        img_CR = modcrop({img_CR},crop_num); 
        low_CR = resize(img_CR, 1/conf.scale^conf.level, conf.interpolate_kernel);
        interpolated_CR = resize(low_CR, conf.scale^conf.level, conf.interpolate_kernel);

        res_RGB_my{i} = ycbcr2rgb(cat(3,res{i},double(interpolated_CB{1}),double(interpolated_CR{1})));
        res_RGB_my_NLM{i} = ycbcr2rgb(cat(3,res_nlm{i},double(interpolated_CB{1}),double(interpolated_CR{1})));
    end
    
    [p, n, x] = fileparts(conf.filenames{i});
    imwrite(res_RGB_my{i},['.\',input_dir,'\results_my_x',num2str(conf.scale),'\',n,'_my',x]);
    imwrite(res_RGB_my_NLM{i},['.\',input_dir,'\results_my_nlm_x',num2str(conf.scale),'\',n,'_my_nlm',x]);
end