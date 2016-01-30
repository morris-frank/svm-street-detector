function MorphPrediction(image, HeatMap)

%Threshold image to get a binary
BinaryHeatMap = im2bw(HeatMap, 0.35);

%Calculate the edges
canny = edge(image, 'canny', [0.03, 0.085]);

%Thicken the detected edges
canny = bwmorph(canny, 'thicken', 7);

%Invert the Edges
canny = imcomplement(canny);

%Removes the detected edges from the binary heatmap
BinaryHeatMap = logical(canny .* BinaryHeatMap);

clear canny

%Wider holes in the reults so  noise can be cutted out
BinaryHeatMap = imopen(BinaryHeatMap, strel('disk', 1));

%Select the part of the results is in front of the car
BinaryHeatMap = bwselect(BinaryHeatMap, [100 640], [450 450], 4);

%One result-body remains and that we want to as compact as possible
%so we fill remaining holes
BinaryHeatMap = imclose(BinaryHeatMap, strel('disk', 7));

HeatMap = HeatMap .* BinaryHeatMap;

showHeatMap(image, HeatMap, 'green')

end