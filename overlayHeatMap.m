function overlayHeatMap(HeatMap, image, color)

if strcmp(color, 'red')
	colorMap = cat(3, ones(size(image), 'single'), zeros(size(image), 'single'), zeros(size(image), 'single'));
end

if strcmp(color, 'green')
	colorMap = cat(3, zeros(size(image), 'single'), ones(size(image), 'single'), zeros(size(image), 'single'));
end

if strcmp(color, 'blue')
	colorMap = cat(3, zeros(size(image), 'single'), zeros(size(image), 'single'), ones(size(image), 'single'));
end

warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')
imshow(image, 'InitialMag', 'fit')
hold on
hn = imshow(colorMap);
hold off
set(hn, 'AlphaData', HeatMap)

end