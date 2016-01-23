%% Task 2
%We mark out a region R using a polygon in a selected image.
%We remove the selected region R and fill it in using the Equation (2) in 
%the paper "Poisson Image Editing"
%We need to find the unknown intensity values inside the region R. 

clear all;
close all;

%Read the input image
targetImg = rgb2gray(imread('greekFlag.jpg'));

%Reshape the target image from 2D to 1D for easier processing and
%neighbor finding
targetImg_1D=reshape(targetImg,size(targetImg,1)*size(targetImg,2),1);

%Display the initial images
fig_src_trg=figure;
set(fig_src_trg, 'Position', [100, 100, 1000,600]);
subplot(2,2,1);
imshow(targetImg);
title('Target Image')
drawnow;

%Prompt user to select a ROI polygon from image
uiwait(msgbox('Please Select a ROI polygon on the image','Notification','modal'));
%Create ROIPOLY region on scenery image(target image)
Mask_Target=roipoly(targetImg);
title('Target Image')
subplot(2,2,2);
imshow(Mask_Target);
title('Mask');

%%
%In case someone wants to use a specific pre-selected Region
% %Crop a rectangle region of target img
% c = [20  100 100 20 ];
% r = [75 75 100 100];
% Mask_Target = roipoly(targetImg,c,r);
% imshow(Mask_Target);
% title('Mask');
tic;
%Get the dimensions of mask Mask_Target
[Height_Mask_Target Width_Mask_Target]=size(Mask_Target);
%Create a 1D vector with the values of Mask_Target 
Mask_Target_1D=reshape(Mask_Target,size(Mask_Target,1)*size(Mask_Target,2),1);
%Mask_Target_1D_Indices has the indices(1D) only where Mask_Target(i,j)==1 columnwise
Mask_Target_1D_Indices=find(Mask_Target_1D);

%% Build matrix A(2D) of the solution 
%Size of A depends on the number of 1s in the mask 
A=sparse(size(Mask_Target_1D_Indices,1),size(Mask_Target_1D_Indices,1));
%Find the edge values, so that we can correctly
%create the diagonal of A later on, since we need to check
%if all the neighbors of pixels are inside the image given
edge_values_left=2:Height_Mask_Target-1;
edge_values_right=((Width_Mask_Target-1)*Height_Mask_Target)+1 : ((Height_Mask_Target * Width_Mask_Target)-1);
edge_values_up=(Height_Mask_Target+1):Height_Mask_Target:((Height_Mask_Target*Width_Mask_Target)-(2*Height_Mask_Target)+1);
edge_values_down=(2*Height_Mask_Target):Height_Mask_Target:(Height_Mask_Target*Width_Mask_Target)-Height_Mask_Target;

%For each pixel of the mask where we have value 1
%We check its relationship with all others pixels 
%of the mask where we have also value 1
%Also we check if the pixel is in the edges or corners of image
Await = waitbar(0,'Calculating A matrix...');
stepsA = size(Mask_Target_1D_Indices,1)*size(Mask_Target_1D_Indices,1);
stepA=1;
corFlagStep=round(stepsA/10);
for i=1:size(Mask_Target_1D_Indices,1)
    for j=1:size(Mask_Target_1D_Indices,1)
        if mod(stepA,corFlagStep)==0
            waitbar(stepA / stepsA)
        end
        stepA=stepA+1;
        if i==j 
            %Check if the pixel i is on the corners
            if     Mask_Target_1D_Indices(i)==1 || ... %Upper left
                   Mask_Target_1D_Indices(i)==Height_Mask_Target || ... %Lower Left
                   Mask_Target_1D_Indices(i)==(Width_Mask_Target*Height_Mask_Target)-(Height_Mask_Target-1) ||... %Upper Right
                   Mask_Target_1D_Indices(i)==Height_Mask_Target * Width_Mask_Target  %Lower Right
                        A(i,j)=2;
            %Check if the pixel i is on one of the edge pixels
            elseif sum(Mask_Target_1D_Indices(i)==edge_values_left) ==1 || ... %Left Edge
                   sum(Mask_Target_1D_Indices(i)==edge_values_right)==1 || ...%Right Edge
                   sum(Mask_Target_1D_Indices(i)==edge_values_up)   ==1 || ...   %Top Edge
                   sum(Mask_Target_1D_Indices(i)==edge_values_down) ==1        %Bottom Edge
                        A(i,j)=3;
            else
                        A(i,j)=4;
            end
        else
            %Find the relationship between pixels of the mask where value=1
            if adjacent(Mask_Target_1D_Indices(i),Mask_Target_1D_Indices(j),Height_Mask_Target)
                A(i,j) = -1;
            else
                A(i,j) = 0;
            end
        end
    end
end
close(Await)

%% Build vector b (size(Mask_Target_1D_Indices) x 1)
%Each element i of the vector b represents the ith pixel of the image
%with mask value 1 and the value of b(i) is the sum of the neighbor pixels 
%intensity of pixel i in the target image, only for the neighbors with
%mask value =0
%SumOfNeighbors( center_index,img_1D,Mask_Target )
b=zeros(size(Mask_Target_1D_Indices,1),1);
%Mask_Target_1D_Indices maps from 1,2.... to the i that have 1 in mask

%Waitbar for calculation of b vector
Bwait = waitbar(0,'Calculating b vector...');
stepsB = size(Mask_Target_1D_Indices,1);
corFlagStepB=round(stepsB/10);
for i=1:size(Mask_Target_1D_Indices,1)
    %Waitbar process
    if mod(i,corFlagStepB)==0
        waitbar(i / stepsB)
    end
       
    %Each element of b is calculated through SumOfNeighbors
    b(i)=SumOfNeighbors( Mask_Target_1D_Indices(i),targetImg_1D,Mask_Target_1D,Height_Mask_Target );
end
close(Bwait)

%Solve the system
x=uint8(A\b);


%% Replace the Mask values with the new ones in the target image
%We only replace the pixels of the mask where mask_value was 1
targetImg_1D(Mask_Target_1D_Indices(:))=x(:);
%Make the new image from 1D to 2D to display 
newTargetImg=reshape(targetImg_1D,size(targetImg,1),size(targetImg,2));
%Display new Image
subplot(2,2, [3 4]);
imshow(newTargetImg);
title('Result');
toc

%Save image and figure
imwrite(newTargetImg,'Result_2_Image.png')
print(fig_src_trg,'Result_2_Figure','-dpng')

