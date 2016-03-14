function [ dict_lores, dict_hires,conf ] = l2_training_dictionary( conf,features,patches,dictsize )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
iteration_num = 500;
lamda = 0.01;
lamda2 = 0.1;    
errl = zeros(iteration_num,1);
P = getpca(features);

D = P;
for iter = 1:iteration_num
    A = double(D'*D);
    alphah = (A + lamda*eye(size(A, 1))) \( D' * features);
    errl(iter) = compute_err(features, D, alphah, lamda);
    B = alphah * alphah';
    D = features*alphah' / (B + lamda2*eye(size(B, 1)));
end
dict_lores = D;

gamma = alphah;
dict_hires = (patches * gamma') * inv(full(gamma * gamma'));

end

