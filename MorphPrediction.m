% See the file 'LICENSE' for the full license governing this code.
function HeatMap = MorphPrediction(HeatMap, image)

%Calculate the edges
canny = edge(image, 'canny', [0.03, 0.085]);

%Thicken the detected edges
canny = bwmorph(canny, 'thicken', 7);

%Invert the Edges
canny = imcomplement(canny);

%Threshold image to get a binary
BinaryHeatMap = im2bw(HeatMap, 0.35);

%Removes the detected edges from the binary heatmap
BinaryHeatMap = logical(canny .* BinaryHeatMap);

clear canny

%Wider holes in the reults so noise can be cutted out
BinaryHeatMap = imopen(BinaryHeatMap, strel('disk', 1));

%Select the region of the results that is in front of the car
BinaryHeatMap = bwselect(BinaryHeatMap, [100 640], [450 450], 4);

%One region remains and this we want to be as compact as possible
%so we fill remaining holes
BinaryHeatMap = imclose(BinaryHeatMap, strel('disk', 10));
BinaryHeatMap = imfill(BinaryHeatMap, 'holes');

HeatMap = HeatMap .* BinaryHeatMap;

end