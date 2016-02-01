% See the file 'LICENSE' for the full license governing this code.
function overlayHeatMap(HeatMap, im, color)

if strcmp(color, 'red')
	colorMap = cat(3, ones(size(im), 'single'), zeros(size(im), 'single'), zeros(size(im), 'single'));
end

if strcmp(color, 'green')
	colorMap = cat(3, zeros(size(im), 'single'), ones(size(im), 'single'), zeros(size(im), 'single'));
end

if strcmp(color, 'blue')
	colorMap = cat(3, zeros(size(im), 'single'), zeros(size(im), 'single'), ones(size(im), 'single'));
end

warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')
f = figure('Visible', 'off');
a = axes('Visible','off');
imagesc(im), colormap(gray), axis off;
hold on
hn = imagesc(colorMap), axis off;
hold off
set(hn, 'AlphaData', HeatMap)
print('MySavedPlot','-dpng', '-noui')

end