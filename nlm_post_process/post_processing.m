function im_post = post_processing(im, y, zooming, gama, tao)
%%Post Processing
[N, ~]       =   Compute_NLM_Matrix( im, 7);
NTN          =   N'*N*gama;
[im_h, im_w] =size(im);
%im_f = sparse(double(im(:)));
im_f = double(im(:));
T = 80;
err =zeros(T, 1);
i = 1;
while i <= T 
    Z = compute_du_sample(im_f, y, zooming,im_h, im_w);
    im_f = im_f  - tao*(Z + NTN*im_f);
    err(i) = norm(Z + NTN*im_f);
    if i > 2
        if err(i) > err(i - 1)
            break;
        end
    end
    i = i + 1;
end
im_post = reshape(full(im_f), im_h, im_w);
end