function HeatMap = MP2(HeatMap, Image)

    canny = edge(Image, 'canny', [0.01, 0.07]);
    canny = imclose(canny, strel('disk', 5));
    canny = imcomplement(canny);
    
    BinaryHeatMap = im2bw(HeatMap, 0.35);
    
    BinaryHeatMap = logical(canny .* BinaryHeatMap);
    
    BinaryHeatMap = bwareafilt(BinaryHeatMap, 1);
    
    BinaryHeatMap = imdilate(BinaryHeatMap, strel('disk', 2));
    
    HeatMap = BinaryHeatMap;
end