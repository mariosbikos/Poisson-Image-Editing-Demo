function [ isNeighbor ] = adjacent( center_index,neighbor_index, height )
%adjacent Returns a boolean depending on whether the center_index(1d)
%parameter is a neighbor with the neighbor_index(1d) in an image based on its
%height
%   To check its neighbor, this function has to manipulate the center_index
%   value to see if it matches with the value of its neighbors


%If the neighbor_index given is a neighbor of the center_index
if (center_index-1==neighbor_index     || ...  %Top Neighbor
   center_index+1==neighbor_index      || ...  %Bottom Neighbor
   center_index-height==neighbor_index || ...  %Left Neighbor
   center_index+height==neighbor_index )       %Right Neighbor 
        isNeighbor=1;
else 
        isNeighbor=0;
end

end

