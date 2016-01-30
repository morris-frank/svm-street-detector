function MorphPrediction(image, HeatMapPositiv)

%Threshold image to get a binary
posBw = im2bw(HeatMapPositiv, 0.35);

%Calculate the edges
canny = edge(image, 'canny', [0.03, 0.085]);

%Thicken the detected edges
canny = bwmorph(canny, 'thicken', 2);

%invert the edges
canny = imcomplement(canny);

posBw = logical(canny .* posBw);

se = strel('disk',1);

posBw = imopen(posBw, se);

posBw = bwselect(posBw, [100 850], [450 450], 4);

se = strel('disk',10);

posBw = imclose(posBw, se);

showHeatMap(image, posBw, 'green')
%imshow(posBw)

end