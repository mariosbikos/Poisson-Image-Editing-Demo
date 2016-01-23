function [ finalSum ] = SumOfNeighbors( center_index,img_1D,Mask_1D,height )
%SumOfNeighbors Sum the intensity values of the img_1D of the neighbors of
%center_index which are 0.
%   After we check each neighbor's pixel value on the mask
%   if it is 0, then we add the intensity to the finalSum

%For 4 neighbors
finalSum= (1-Mask_1D(center_index-1))      * double(img_1D(center_index-1)) + ...
          (1-Mask_1D(center_index+1))      * double(img_1D(center_index+1)) + ...
          (1-Mask_1D(center_index-height)) * double(img_1D(center_index-height))+ ...
          (1-Mask_1D(center_index+height)) * double(img_1D(center_index+height));

end

