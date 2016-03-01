function [imgsWave,imgs,imgsCB,imgsCR] = load_images(paths, wavelet_scale, wavelet_name)
if nargin < 2
    wavelet_name = 'bior4.4';
end

imgsWave=cell(size(paths),4,wavelet_scale);
imgs = cell(size(paths));
imgsCB = cell(size(paths));
imgsCR = cell(size(paths));
for i = 1:numel(paths)
    X = imread(paths{i});
    if size(X, 3) == 3 % we extract our features from Y channel
        X = rgb2ycbcr(X);                   
        imgsCB{i} = im2single(X(:,:,2)); 
        imgsCR{i} = im2single(X(:,:,3));
        X = X(:, :, 1);
    end
    X = im2double(X); % to reduce memory usage
    imgs{i} = X;
    for j=1:wavelet_scale
        [imgsWave{i,1,j},imgsWave{i,2,j},imgsWave{i,3,j},imgsWave{i,4,j}]=dwt2(X,wavelet_name);%bior4.4
        X=imgsWave{i,1,j};
    end
end

end
