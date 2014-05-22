function [U,lambda] = effSpectralClustering( A, selected, evec )
%%%%%%%%%%%%%%%%% INPUT : non-symmetric A:1 with size n*m %%%%%%%%%%%%%%%%%
[r,c] = size(A);

A_11 = A(selected,:);
degs = A_11 * ones(size(A_11,2),1);
D_star = spdiags(1./(degs.^0.5+eps),0,size(A_11, 1), size(A_11, 2));
M_star = D_star * A_11 * D_star;
M_star = (M_star + M_star')/2; % Make sure M is symmetric (numerical inaccuracy)

whos M_star

opts.issym = 1;
%opts.isreal = 1;
opts.disp = 0;
opts.tol = 1e-3;
[V,lambda] = eigs(M_star,evec,'la',opts);

B = D_star * V * pinv(lambda);

Q = sparse(A * B); 
clear B; clear M_star; clear D_star; clear A_11; clear A;


degs = (Q * lambda) * (Q' * ones(size(Q',2),1));

D_approx    = spdiags(1./(degs.^0.5+eps),0,r,r);
U = D_approx * Q;


%%%%%%%%%%%%%%%%%%%%INPUT: Upper Triangular matrix of Symmetric A with size n*n %%%%%%%%%%%%%%%%%%%%%%%%%%

% [r,c] = size(A);
% m = size(selected,2);
% 
% A_11 = A(selected,selected);
% upA_11 = triu(A_11); % m*m 
% 
% dUpA_11 = upA_11 * ones(size(upA_11,2),1);
% dLowA_11 = upA_11' * ones(size(upA_11',2),1);
% degs = dUpA_11 + dLowA_11 - diag(upA_11);
% 
% D_star = spdiags(1./(degs.^0.5),0,size(A_11, 1), size(A_11, 2));
% upD_star = triu(D_star);
% 
% upM_star = upD_star * upA_11 * upD_star;
% upM_star = (upM_star + upM_star')/2; % Make sure M is symmetric (numerical inaccuracy)
% 
% opts.issym = 1;
% opts.disp = 0;
% opts.tol = 1e-3;
% [V,lambda] = eigs(@(x)multfunc(x,upM_star),size(upM_star,1),evec,'la',opts);
% 
% B = D_star * V * pinv(lambda);
% 
% Q = sparse(r,evec);
% for i = 1:r
%     z=zeros(1,r);
%     z(1,i) = A(i,i);
%     a = A(i,:) + A(:,i)' - z; 
%     a = a(1,selected);
%     Q(i,:) = a * B;
%     
% end
% % upA = triu(A,1) + diag(diag(A)/2);

% % upA = upA(:,selected);
% % Q = sparse((upA * B) + (B' * upA')');
% 
% clear B; clear M_star; clear D_star; clear A_11; clear A;
% 
% 
% degs = (Q * lambda) * (Q' * ones(size(Q',2),1));
% 
% D_approx    = spdiags(1./(degs.^0.5),0,r,r);
% U = D_approx * Q;



end
