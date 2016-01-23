function [ width,height,upper_left_coords,lower_right_coords ] = FindAABBofMask( mask )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
maxX=0;
maxY=0;
minX=9999;
minY=9999;
for i=1:size(mask,1)
    for j=1:size(mask,2)
        %We want to find the minX,minY and maxX,maxY where exists 1
        %It is like AABB
        if mask(i,j)==1 
            if i<minX
                minX=i;
            end
            if i>maxX
                maxX=i;
            end
            if j<minY
                minY=j;
            end
            if j>maxY
                maxY=j;
            end
            
        end
    end
end
upper_left_coords=[minX minY];
lower_right_coords= [maxX maxY];


width=lower_right_coords(2)-upper_left_coords(2)+1;
height=lower_right_coords(1)-upper_left_coords(1)+1;

end

