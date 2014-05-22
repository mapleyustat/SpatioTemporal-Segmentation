function [U_hat,lambda_hat] = orthogonalize(U,lambda,evec)
P = U' * U;
opts.disp = 0;
[V,Sigma] = eigs(P,evec,'lr',opts);
B = Sigma.^(0.5) * V' * lambda * V * Sigma.^(0.5);
[V_hat,lambda_hat] = eigs(B,evec,'lr',opts);
U_hat = U * V * diag(diag(Sigma.^(-0.5))) * V_hat;
end