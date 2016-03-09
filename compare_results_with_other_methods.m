clear all;
close all;
clc;

upscaling = 3;
wavelet_scale = 2;
crop_num = lcm(upscaling,wavelet_scale);
upsample_factor = upscaling;
input_dir = 'Set5'; % Directory with input images from Set5 image dataset
% input_dir = 'Set14'; % Directory with input images from Set14 image dataset
pattern = '*.bmp'; % Pattern to process
dict_sizes = 1024;
border = [1 1];

GTfilenames = glob(input_dir, pattern); % Cell array
[imgs_testGT,imgsCB_testGT,imgsCR_testGT] = load_images(GTfilenames);

index = ['\results_my_nlm_X',num2str(upscaling),'\'];
MYfilenames = glob([input_dir,index], pattern);
[imgs_my_nlm,imgsCB_my_nlm,imgsCR_my_nlm] = load_images(MYfilenames);

res_PSNR = zeros(numel(MYfilenames),1);
for i=1:numel(MYfilenames)
    img = imgs_testGT{i};
    img = modcrop({img},crop_num);
    
%     img_inter = resize(img,1/upscaling,'bicubic');
%     img_inter = resize(img_inter,upscaling,'bicubic');
%     img_my = img_inter;

    img_my = imgs_my_nlm{i};
    img_my = modcrop({img_my},crop_num);

    img{1} = uint8(img{1}*255);
    img_my{1} = uint8(img_my{1}*255);
    img{1} = im2double(img{1});
    img_my{1} = im2double(img_my{1});
    res_PSNR(i,1) = cal_PSNR(img{1}(1+border(1)*upscaling:end-border(1)*upscaling,1+border(2)*upscaling:end-border(2)*upscaling),...
        img_my{1}(1+border(1)*upscaling:end-border(1)*upscaling,1+border(2)*upscaling:end-border(2)*upscaling));
end