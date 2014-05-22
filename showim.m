function  showim(Data,D,number,m,n,k,root)

roundColors = 0;        % Round color values for less strict uniqueness
roundDigits = 2;        % Precision for Uniqueness
markEdges   = 0;        % Outline edges

root_results = fullfile(root,'TSP_results/');
files = dir([root '*.png']);



if isequal(roundColors, 1)
    fac = 10^roundDigits;
    rData = round(Data * fac) / fac;
else
    
    rData = Data;
end


if k == 2
    map = [0 0 0; 1 1 1];
    
else
    map = zeros(3, k);
    for ii = 1:max(D)
        ind = find(D == ii, 1);
        map(:, ii) = rData(:, ind);
    end
    
    map = map';
    
end



for i=1:number
    imgD = D((i-1)*m*n+1:(i-1)*m*n+m*n,1);
    S = reshape(imgD, m, n);
    Im = imread([root files(i).name]);
     Im = imresize(Im,0.5);
    % choose colormap
    
    
    % plot image
    if isequal(markEdges, 1)
        
        
        Im = imread([root files(i).name]);
        imshow(Im, 'Border', 'tight');
        
        
        lS = label2rgb(S);
        BW = im2bw(lS, graythresh(lS));
        
        [B, L] = bwboundaries(BW, 'holes');
        
        hold on;
        
        for k = 1:length(B)
            boundary = B{k};
            plot(boundary(:, 2), boundary(:, 1), 'r', 'LineWidth', 1)
        end
        hold off;
        
    else
        
        figure;
        imshow(S, map, 'Border', 'tight');
        outname = fullfile(root_results,[files(i).name '.mat']);
        save(outname,'S');
%         [Label,regionNum] = RegionMerging(S,Im);
%         outname = fullfile(root_results,[files(i).name '_merged.mat']);
%         save(outname,'Label');
%         figure; 
%         imagesc(Label);
        
        
    end
    
    
    

end



end