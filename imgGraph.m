function graph = imgGraph(Img,R)

% fprintf('Creating Similarity Graph...\n');
% tic
graph = imAffinity(Img,R);
[~,graph, ~] = scale_dist(graph,1);
% toc




end