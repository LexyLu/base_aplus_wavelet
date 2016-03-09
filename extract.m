function [features] = extract(conf, X, scale, filters)

% Compute one grid for all filters
grid = sampling_grid([size(X,1),size(X,2)], ...
    conf.window, conf.overlap, conf.border, scale);
feature_size = prod(conf.window) * numel(conf.filters) * (conf.scale^2)* size(X,3);

% Current image features extraction [feature x index]
if isempty(filters)
    features = zeros([size(grid,1)*size(grid,2)*size(X,3) size(grid,3)]);
    for i=1:size(X,3)
        temp = X(:,:,i);
        f = temp(grid);
        f = reshape(f, [size(f, 1) * size(f, 2) size(f, 3)]);
        features((1:size(f, 1)) + (i-1)*size(f, 1), :) = f;
    end
else
    features = zeros([feature_size size(grid, 3)], 'single');
    for j=1:size(X,3)
        temp = X(:,:,i);
        for i = 1:numel(filters)
            f = conv2(temp, filters{i}, 'same');
            f = f(grid);
            f = reshape(f, [size(f, 1) * size(f, 2) size(f, 3)]);
            features((1:size(f, 1)) + (i-1)*size(f, 1) + (j-1)*numel(filters)*size(f,1), :) = f;
        end
    end
end
