function [output] = admm(A,A_adj,x,b,niter,lambda,rho)

tol = 1e-4;
max_iter = 10;

z = zeros(size(x));
y = zeros(size(x));

lsqr_lhs = @(a) vec(A_adj(A(reshape(a,size(x))))-rho);

n = 1;
while (n<niter+1)
    fprintf('Iteration %d\n',n);
    lsqr_rhs = vec(A_adj(b) - rho*z - y);
    [xhat, ~, ~, ~] = symmlq(lsqr_lhs, lsqr_rhs, tol, max_iter, [], [], x(:));
    x = reshape(xhat, size(x));
    z = SoftThresh(x - y/rho,lambda/rho);
    y = y + rho*(x-z);
    n = n + 1;
end
output = x;

end