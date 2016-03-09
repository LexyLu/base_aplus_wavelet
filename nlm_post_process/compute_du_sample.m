function z = compute_du_sample(im_f, y, zooming, im_h, im_w)
%%up and down sampling
im_f = reshape(im_f, im_h, im_w);
x = imresize(im_f, 1/zooming, 'bicubic');
yl = x - y;
z = imresize(yl, zooming, 'bicubic');
z = z(:);
end