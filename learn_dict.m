function [conf] = learn_dict(conf, hires, dictsize , wavelet_scale , wavelet_name)
% Sample patches (from high-res. images) and extract features (from low-res.)
% for the Super Resolution algorithm training phase, using specified scale 
% factor between high-res. and low-res.
if nargin < 5
    wavelet_name = 'bior4.4';
end

% Load training high-res. image set and do the wavelet decomposition then resample it
hires = modcrop(hires, lcm(conf.scale,wavelet_scale)); % crop a bit (to simplify scaling issues)
hires_wave = cell([numel(hires),1]);
for i=1:numel(hires)
    [hires_wave{i}(:,:,1),hires_wave{i}(:,:,2),hires_wave{i}(:,:,3),hires_wave{i}(:,:,4)] = dwt2(hires{i},wavelet_name);
end

% Scale down images
lores = resize(hires, 1/conf.scale, conf.interpolate_kernel);
midres = resize(lores, conf.upsample_factor, conf.interpolate_kernel);
midres_wave = cell([numel(hires) 1]);
for i=1:numel(hires)
    [midres_wave{i}(:,:,1),midres_wave{i}(:,:,2),midres_wave{i}(:,:,3),midres_wave{i}(:,:,4)] = dwt2(midres{i},wavelet_name);
end
features = collect(conf, midres_wave, conf.upsample_factor,{});%conf.filters
clear midres
clear lores

for i=1:numel(hires)
    hires_wave{i} = hires_wave{i} - midres_wave{i};
end

patches = collect(conf, hires_wave, conf.scale, {});

for j=1:4
    [ dict_lores, dict_hires,conf] = l1_training_dictionary( conf,features((1:prod(conf.window)*conf.scale^2) + (j-1)*prod(conf.window)*conf.scale^2,:), ...
        patches((1:prod(conf.window)*conf.scale^2) + (j-1)*prod(conf.window)*conf.scale^2,:),dictsize );
    if j==1
        conf.dict_loresLL = dict_lores;
        conf.dict_hiresLL = dict_hires;
        conf.V_pca_LL = conf.V_pca;
    elseif j==2
        conf.dict_loresLH = dict_lores;
        conf.dict_hiresLH = dict_hires;
        conf.V_pca_LH= conf.V_pca;
    elseif j==3
        conf.dict_loresHL = dict_lores;
        conf.dict_hiresHL = dict_hires;
        conf.V_pca_HL = conf.V_pca;
    elseif j==4
        conf.dict_loresHH = dict_lores;
        conf.dict_hiresHH = dict_hires;
        conf.V_pca_HH = conf.V_pca;
    end
end
% [ dict_lores, dict_hires,conf] = l1_training_dictionary( conf,features, ...
%         patches,dictsize );
%     conf.dict_lores = dict_lores;
%         conf.dict_hires = dict_hires;
