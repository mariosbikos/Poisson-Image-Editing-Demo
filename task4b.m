%% Task 4b
% RGB IMAGES
% SEAMLESS CLONING-Mixing Gradients  
% Here apart from the intensity values of the neighbors of mask pixels
%that don't belong to the mask, we also check for each pixel of the mask
%for each of the 4 neighbors the absolute difference between
% 1)the difference of intensities of center pixel and neighbor pixel (both of Source) 
% 2)the difference of intensities of center pixel and neighbor pixel (both of Target) 
%According to which is greater, we take this difference and add it to the
%sum( we have one value for each of the 4 neighbors) for creating b vector


clear all;
close all;

%Read the input images
srcImg    = imread('tatoo.jpg');
targetImg = imread('me2.jpg');

%Reshape the target image from 2D to 1D
targetImg_1D=reshape(targetImg,size(targetImg,1)*size(targetImg,2),3);
srcImg_1D=reshape(srcImg,size(srcImg,1)*size(srcImg,2),3);

%Display the initial images
fig_src_trg=figure;
set(fig_src_trg, 'Position', [100, 100, 1000,600]);
figure(fig_src_trg);
subplot(2,2,2);
imshow(targetImg);
title('Target Image')
subplot(2,2,1);
imshow(srcImg);
title('Source Image')
drawnow;
%Prompt user to select a ROI polygon from image
uiwait(msgbox('Please Select a ROI polygon on the Source Image','Notification','modal'));
Mask_Source=roipoly(srcImg);
title('Source Image')
subplot(2,2,3);
imshow(Mask_Source);
title('Mask on Source');

%Diplay the source image in a new figure, for the user to better
%determine where to paste the cropped source image
fig_selection = figure;
figure(fig_selection);
imshow(targetImg)
set(fig_selection, 'Position', [100, 100, 1000,600]);
title('Target Image');
%Prompt user to select a pixel to paste the source image selected
uiwait(msgbox('Please Select an pixel point to paste the source image','Notification','modal'));
[startY, startX] = getpts(fig_selection);
Print='User selected to paste source image to region starting from upper left position: '
startX=round(startX)
startY=round(startY)

%Get the dimensions of mask Mask_Source
[height_MaskOfSource width_MaskOfSource]=size(Mask_Source);
%Create a 1D vector with the values of Mask_Source 
Mask_Source_1D=reshape(Mask_Source,size(Mask_Source,1)*size(Mask_Source,2),1);
%Mask_Source_1D_Indices has the indices(1D) only where Mask_Source(i,j)==1 columnwise
Mask_Source_1D_Indices=find(Mask_Source_1D);






%% Build matrix A(2D) of the solution
A=sparse(size(Mask_Source_1D_Indices,1),size(Mask_Source_1D_Indices,1));
%Find the edge values, so that we can correctly
%create the diagonal of A later on, since we need to check
%if all the neighbors of pixels are inside the image given
edge_values_left=2:height_MaskOfSource-1;
edge_values_right=((width_MaskOfSource-1)*height_MaskOfSource)+1 : ((height_MaskOfSource * width_MaskOfSource)-1);
edge_values_up=(height_MaskOfSource+1):height_MaskOfSource:((height_MaskOfSource*width_MaskOfSource)-(2*height_MaskOfSource)+1);
edge_values_down=(2*height_MaskOfSource):height_MaskOfSource:(height_MaskOfSource*width_MaskOfSource)-height_MaskOfSource;


%For each pixel of the mask where we have value 1
%We check its relationship with all others pixels 
%of the mask where we have also value 1
%Also we check if the pixel is in the edges or corners of image



for i=1:size(Mask_Source_1D_Indices)
    for j=1:size(Mask_Source_1D_Indices)
        if i==j 
            %Check if the pixel i is on the edges
            if     Mask_Source_1D_Indices(i)==1 || ... %Upper left
                   Mask_Source_1D_Indices(i)==height_MaskOfSource || ... %Lower Left
                   Mask_Source_1D_Indices(i)==(width_MaskOfSource*height_MaskOfSource)-(height_MaskOfSource-1) ||... %Upper Right
                   Mask_Source_1D_Indices(i)==height_MaskOfSource * width_MaskOfSource  %Lower Right
                        A(i,j)=2;
            elseif sum(Mask_Source_1D_Indices(i)==edge_values_left) ==1 || ... %Left Edge
                   sum(Mask_Source_1D_Indices(i)==edge_values_right)==1 || ...%Right Edge
                   sum(Mask_Source_1D_Indices(i)==edge_values_up)   ==1 || ...   %Top Edge
                   sum(Mask_Source_1D_Indices(i)==edge_values_down) ==1        %Bottom Edge
                        A(i,j)=3;
            else
                        A(i,j)=4;
            end
        else
            if adjacent(Mask_Source_1D_Indices(i),Mask_Source_1D_Indices(j),height_MaskOfSource)
                A(i,j) = -1;
            else
                A(i,j) = 0;
            end
        end
    end
end

%Based on the Mask of Source, find the AABB(the total rectangle which
%surrounds the crop area--> width,height,upper left pixel,lower right pixel
[Maskwidth,Maskheight,upper_left_coords,lower_right_coords ] = FindAABBofMask( Mask_Source );
%cropArea is the defined AABB with 0 and 1 that we will move to Target Mask later
cropArea=Mask_Source(upper_left_coords(1):lower_right_coords(1),upper_left_coords(2):lower_right_coords(2));


%Create a Mask on target based on the starting pixel position
%given by the user and the AABB of the source mask
%Technically, we take adjust the masked pixels of source image
%to create a mask on the target image with the mapped pixels correctly
%set to 1 in MaskOfTarget
MaskOfTarget=zeros(size(targetImg,1),size(targetImg,2));
MaskOfTarget(startX:startX+Maskheight-1,startY:startY+Maskwidth-1) = cropArea;


figure(fig_src_trg);
subplot(2,2,4);
imshow(MaskOfTarget);

%Get the dimensions of maskOfTarget
[height_MaskOfTarget width_MaskOfTarget]=size(MaskOfTarget);
%Create a 1D vector with the values of MaskOfTarget
MaskOfTarget_1D=reshape(MaskOfTarget,size(MaskOfTarget,1)*size(MaskOfTarget,2),1);
%MaskOfTarget_indices has the indices(1D) only where MaskOfTarget(i,j)==1 columnwise
MaskOfTarget_indices=find(MaskOfTarget_1D);


%% Build vector b (size(Mask_Target_1D_Indices) x 3)

b=zeros(size(Mask_Source_1D_Indices,1),3);
%Mask_Source_1D_Indices maps from 1,2.... to the i that have 1 in mask

%Waitbar for calculation of b vector
Bwait = waitbar(0,'Calculating b vector...');
stepsB = size(Mask_Source_1D_Indices,1);
corFlagStepB=round(stepsB/10);
for i=1:size(Mask_Source_1D_Indices,1)
    %Each element of b is calculated through SumOfNeighbors
    %Waitbar process
    if mod(i,corFlagStepB)==0
        waitbar(i / stepsB)
    end
    for channel=1:3
    b(i,channel)=SumOfNeighbors( MaskOfTarget_indices(i),targetImg_1D(:,channel),MaskOfTarget_1D,height_MaskOfTarget )+...
        SumOfMixingGradients(Mask_Source_1D_Indices(i),srcImg_1D(:,channel),height_MaskOfSource,MaskOfTarget_indices(i),...
        targetImg_1D(:,channel),height_MaskOfTarget);
    end
end
close(Bwait);

%Solve the system
x=zeros(size(Mask_Source_1D_Indices,1),3);
x=uint8(A\b);

%% Replace the Mask values with the new ones in the target image
targetImg_1D(MaskOfTarget_indices(:),:)=x;
%Make the new image from 1D to 2D to display 
newTargetImg=reshape(targetImg_1D,size(targetImg,1),size(targetImg,2),3);

%Display new Image
res_fig=figure;
subplot(2,2,2);
imshow(targetImg);
title('Target Image')
subplot(2,2,1);
imshow(srcImg);
title('Source Image')
subplot(2,2,[3 4]);
imshow(newTargetImg);
title('Result');


%Save image and figure
imwrite(newTargetImg,'Result_4b_Image.png')
print(res_fig,'Result_4b_Figure','-dpng')


