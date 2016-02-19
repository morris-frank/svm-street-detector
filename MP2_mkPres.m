function HeatMap = MP2_mkPres(HeatMap, Image, name)

    canny = edge(Image, 'canny', [0.01, 0.07]);
    imwrite(canny, [name '_edge.png'])
    canny = imclose(canny, strel('disk', 5));
    imwrite(canny, [name '_edge_closed.png'])
    canny = imcomplement(canny);
    
    BinaryHeatMap = im2bw(HeatMap, 0.35);
    imwrite(BinaryHeatMap, [name '_bw.png'])
    
    BinaryHeatMap = logical(canny .* BinaryHeatMap);
    imwrite(BinaryHeatMap, [name '_bw_mult.png'])
    
    BinaryHeatMap = bwareafilt(BinaryHeatMap, 1);
    imwrite(BinaryHeatMap, [name '_bw_filt.png'])
    
    BinaryHeatMap = imdilate(BinaryHeatMap, strel('disk', 2));
    imwrite(BinaryHeatMap, [name '_bw_dilated.png'])
    
    HeatMap = BinaryHeatMap;
end
