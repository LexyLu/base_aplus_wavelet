function P =getpca(X)

%X: MxN matrix (M dimensions, N trials)
%Y: Y=P*X
%P: the transform matrix
%V: the variance vector

[~,N]=size(X);

mx   =  mean(X,2);
mx2  =  repmat(mx,1,N);

X=X-mx2;

CovX=X*X'/(N-1);
[P, S, ~] = svd(CovX);

index = (eig(S)/sum(eig(S))) > 0.01;
P= P(:,1:sum(index));

end
