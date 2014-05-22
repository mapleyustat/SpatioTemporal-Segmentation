function graph = flowGraph(IM1, IM2, flow)

% fprintf('Creating Similarity Flow Graph...\n');
% tic
graph = flowdist(IM1, IM2, flow);
[~,graph, ~] = scale_dist(graph,1);
% toc


end