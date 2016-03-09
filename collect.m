function [features] = collect(conf, imgs, scale, filters)

num_of_imgs = size(imgs,1);
feature_cell = cell(num_of_imgs,1); % contains images' features
num_of_features = 0;

feature_size = [];

for i = 1:num_of_imgs
    
    F = extract(conf, imgs{i}, scale, filters);
    num_of_features = num_of_features + size(F, 2);
    feature_cell{i} = F;

    feature_size = size(F, 1);
end
clear imgs % to save memory
features = zeros([feature_size num_of_features]);
offset = 0;
for i = 1:num_of_imgs
    F = feature_cell{i};
    N = size(F, 2); % number of features in current cell
    features(:, (1:N) + offset) = F;
    offset = offset + N;
end
