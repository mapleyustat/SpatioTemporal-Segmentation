function D = RunSegmentation(graph,k,evec, selected)

fprintf('Clustering Data...\n');

C = SpectralClustering(graph, k, evec, selected);
% convert and restore full size
D = convertClusterVector(C);

end