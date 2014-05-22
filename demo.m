function  demo(R,k,evec,sample,root,framesNo)

run('vlfeat-0.9.18/toolbox/vl_setup')

%root = 'sequences/dance/';
root_results = fullfile(root,'TSP_results/');
root_flows = fullfile(root,'TSP_flows/');
root_graphs = fullfile(root,'TSP_graphs/');
files = dir([root '*.png']);

if (~exist(root_graphs,'dir'))
    mkdir(root_graphs);
end

if (~exist(root_results,'dir'))
    mkdir(root_results);
end

if (~exist(root_flows,'dir'))
    mkdir(root_flows);
    disp('Precomputing all the optical flows...');
    for f=2:numel(files)
        
        im1 = imread(fullfile(root,files(f-1).name));
        im1 = imresize(im1,0.5);
        im2 = imread(fullfile(root,files(f).name));
        im2 = imresize(im2,0.5);
        outname = fullfile(root_flows,[files(f).name(1:end-4) '_flow.mat']);
        
        disp([' -> ' outname]);
        compute_of(im1,im2,outname);
    end
end

disp(' -> Optical flow calculations done');
flow_files = dir([root_flows '*_flow.mat']);


if (~exist('frames','var') || isempty(frames))
    frames = 1:numel(files);
else
    frames(frames>numel(files)) = [];
end


disp('Start Building the graph');

image = imread([root files(1).name]);
image = imresize(image, 0.5);
[m, n, d] = size(image);


frame_size = framesNo;
window_size = 2 ;

rep = ceil(frame_size/window_size);


pixelsNum = m * n;
bigGraph = sparse(pixelsNum * frame_size,pixelsNum * frame_size);
totalSelected = [];
Data = [];
windowSelected = [];
selectedPixels = floor(sample*pixelsNum);
bigI = [];
bigJ = [];
bigV = [];
selected = [];
tic


% randomly sample columns
for w = 1:frame_size
h = ones(1,length(selectedPixels)).*((w-1)*pixelsNum);
indices = randperm(pixelsNum);
sel = indices(1:selectedPixels)+h;
selected = vertcat(selected,sel);
end


for w = 1:frame_size
    
    disp([' -> Frame '  num2str(w) ' / ' num2str(numel(frames))]);
    fprintf('Creating Similarity Graph...\n');
    
    tic
    beforeF = [];
    afterF = [];
    before = w-1;
    after = w+1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if before >= 1

        image1 = imread([root files(before).name]);
        image1 = imresize(image1, 0.5);
        image2 = imread([root files(w).name]);
        image2 = imresize(image2, 0.5);
        
        % load the optical flow
        optical = load([root_flows flow_files(before).name]);
        F = flowGraph(image1,image2,optical.flow);
        beforeF = F(pixelsNum+1:end,1:pixelsNum);
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    image = imread([root files(w).name]);
    image = imresize(image, 0.5);
    [m, n, d] = size(image);
    data = reshape(image, 1, m * n, []);
    
    if d >= 2
        data = (squeeze(data))';
    end
    
    data = double(data);
    data = normalizeData(data);
    
    Data = horzcat(Data,data);
    
    G = imgGraph(image,R);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if after <= frame_size
        
        image1 = imread([root files(w).name]);
        image1 = imresize(image1, 0.5);
        image2 = imread([root files(after).name]);
        image2 = imresize(image2, 0.5);
        
        % load the optical flow
        optical = load([root_flows flow_files(w).name]);
        F = flowGraph(image1,image2,optical.flow);
        afterF = F(1:pixelsNum,pixelsNum+1:end);
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    toc
    
    beforeFIdx = [];
    imgIdx = [];
    afterFIdx = [];
    count=0;
    b = false;
    a = false;
    
    
    if size(beforeF,1) > 0
        
        beforeFIdx = selected(w-1,:);
        count=count+1;
        b = true;
    end
    
    
    imgIdx = selected(w,:);
    count=count+1;
    
    if size(afterF,1) > 0
        
        afterFIdx = selected(w+1,:);
        count=count+1;
        a = true;
    end
    
    graph = sparse(pixelsNum,count*pixelsNum);
    
    if b == true & a == true
        graph(1:size(beforeF,1),1:size(beforeF,2)) = beforeF;
        graph(:,pixelsNum+1:2*pixelsNum) = G;
        graph(1:size(afterF,1),2*pixelsNum+1:2*pixelsNum+size(afterF,2)) = afterF;
        begin = w-1;
    
    elseif b == true & a == false
        graph(1:size(beforeF,1),1:size(beforeF,2)) = beforeF;
        graph(:,pixelsNum+1:2*pixelsNum) = G;
        begin = w-1;
    
    elseif b == false & a == true
        graph(:,1:pixelsNum) = G;
        graph(1:size(afterF,1),pixelsNum+1:pixelsNum+size(afterF,2)) = afterF;
        begin = 1;
    end
    
    idx = horzcat(beforeFIdx,imgIdx,afterFIdx);
    
     selectedCol = idx - (begin-1)*pixelsNum;
     selectedGraph = sparse(pixelsNum,count*pixelsNum); 
     selectedGraph(:,selectedCol) = graph(:,selectedCol);

    [I,J,V] = find(selectedGraph);
    h = ones(length(I),1)*((w-1)*pixelsNum);
    I = I + h;
    q = ones(length(J),1)*((begin-1)*pixelsNum);
    J = J + q;
    bigI = horzcat(bigI,I');
    bigJ = horzcat(bigJ,J');
    bigV = horzcat(bigV,V');
    clear graph G F;
end


bigGraph = sparse(bigI,bigJ,bigV);
clear bigI bigJ bigV;


bigGraph = bigGraph(:,selected(:));
D = RunSegmentation(bigGraph,k,evec,selected(:));
showim(Data,D,frame_size,m,n,k,root);
save_all_figures_to_directory(root_results)
clear bigGraph;
clear Data;

toc

end


