function [C, L, U] = SpectralClustering(W, k, evec, selected)

fprintf('Nystrom approximation ...\n');

tic
[U,lambda] = effSpectralClustering(W,selected,evec);
[U_hat,~] = orthogonalize(U,lambda,evec);
U = U_hat;
toc

for i=1:size(U,1); U(i,:)=U(i,:)/(norm(U(i,:))+eps); end

fprintf('K-means ...\n');

tic
[~,C] = vl_kmeans(U',k);
toc

C = sparse(1:size(W, 1), double(C), 1);

end