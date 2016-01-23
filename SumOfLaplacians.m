function [ output ] = SumOfLaplacians( center_index,img_1D,height )
%SumOfLaplacians Returns the sum of the laplacians for a specific
%center_index pixel


output = ...
    4*(double(img_1D(center_index)))-double(img_1D(center_index-1))- ...
    double(img_1D(center_index+1))-double(img_1D(center_index-height))-...
    double(img_1D(center_index+height));

end

