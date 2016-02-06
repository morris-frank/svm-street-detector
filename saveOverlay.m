% See the file 'LICENSE' for the full license governing this code.
function saveOverlay(HeatMap, im, savePath)

green = HeatMap + (im .* (1-HeatMap));

redNBlue = (im .* (1-HeatMap)) - HeatMap;

imwrite(cat(3, redNBlue, green, redNBlue), savePath)
end
