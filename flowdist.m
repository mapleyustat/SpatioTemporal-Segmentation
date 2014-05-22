function F = flowdist(IM1,IM2,flow)

%TO DO: write a function that reads an image and builds the graph
%       and then write a function that builds the graph for the flow
%       between two images and then we need a function that can combine
%       these graphs together and get the full graph. Run scale dist on
%       just the image graphs and not on the flow graphs. 




if( max(IM1(:)) > 1 )
    IM1 = double(IM1)/255.0;
end

if( max(IM2(:)) > 1 )
    IM2 = double(IM2)/255.0;
end



F = mkFlowDist(IM1(:,:,1),IM2(:,:,1),flow);

    
%% if there is more than one color channel sum all the distances
% note, that all channels have the same fill pattern in the distance
% matrix
for c = 2:size(IM1,3),
    F1 = mkFlowDist(IM1(:,:,c),IM2(:,:,c),flow);
    F = F+F1;
    clear F1; 
end

F(find(F == 3*eps)) = 0;

return;


end





function graph = mkFlowDist(IM1, IM2, flow)

%u matrix for flow x
%v matrix for flow y

 
% optical flow returns actual x and y flow... flip it
u = flow.bvy;
v = flow.bvx;

[rows1,cols1,colors1]=size(IM1);
[rows2,cols2,colors2] = size(IM2);

O = ones(9,1);
DX = ceil(repmat([1:rows2]',1,cols2) + u);
DY = ceil(repmat([1:cols2],rows2,1) + v);
I = find(DX(:) > 0 & DY(:) > 0 & DX(:) <= rows1 & DY(:) <= cols1); %IM2(I)--->IM1(DX,DY) and all its 9 neighbors
Im1Index = (DY(I)-1)*rows1 + DX(I);
clear DX; clear DY;

IndIm1=reshape(1:(rows1*cols1),rows1,cols1); % 1-rows*cols
IndIm2=reshape(rows1*cols1+1:(2*rows2*cols2),rows2,cols2); %rows*cols+1-rows*cols*2

BigIm1=addborder(IM1,1,1,0); %added border to IM1 
IndImage=addborder(IndIm1,1,1,0); %added border to the index of pixels in IM1 (columnwise)
A1 = im2col(BigIm1,[3 3],'sliding'); %value of 8 connected neighbors for each pixel
Ind1 = im2col(IndImage, [3 3], 'sliding'); %index of 8 connected neighbors for each pixel 

Im1Val = A1(:,Im1Index); clear A1;
Im1Ind = Ind1(:,Im1Index); clear Ind1;

Im2Val = O*IM2(I)';
Im2Ind = O*IndIm2(I)';

Index = find(Im1Ind(:) > 0 & Im2Ind(:) > 0);
im1V = Im1Val(Index); clear Im1Val;
im1I = Im1Ind(Index); clear Im1Ind;

im2V = Im2Val(Index); clear Im2Val;
im2I = Im2Ind(Index); clear Im2Ind;

idx1 = vertcat(im1I,im2I);
idx2 = vertcat(im2I,im1I);

Dff = (im1V - im2V).^2 + eps;
D = vertcat(Dff,Dff);
% G=sparse(im2I,im1I,Dff);
% G = G(rows1*cols1+1:end,1:rows1*cols1);
% graph = zeros(rows1*cols1*2,rows1*cols1*2);
% graph(rows1*cols1+1:size(G,1),1:size(G,2)) = G;
% graph(1,size(G',1),rows1*cols1+1:size(G',2)) = G';

graph = sparse(idx2,idx1,D);
end


