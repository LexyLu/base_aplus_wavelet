function [ res ] = cal_PSNR( F,G )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
E = F - G; % error signal
N = numel(E); % Assume the original signal is at peak (|F|=1)
res = 10*log10( N / sum(E(:).^2) );

end

