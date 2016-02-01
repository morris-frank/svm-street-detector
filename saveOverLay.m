% See the file 'LICENSE' for the full license governing this code.
function saveOverLay(HeatMap, im, savePath)

green = cat(3, zeros(size(im), 'single'), ones(size(im), 'single'), zeros(size(im), 'single'));

warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure')
f = figure('Visible', 'off');
a = axes('Visible','off');
imagesc(im), colormap(gray), axis off;
hold on
hn = imagesc(green); axis off;
hold off
set(hn, 'AlphaData', HeatMap)
print(savePath,'-dpng', '-noui')

end