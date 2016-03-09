function  y = compute_err(X, D, a, lamda)
y = norm(X - D*a)^2 + lamda * norm(a);
end

