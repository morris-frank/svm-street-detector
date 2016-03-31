function RemoveGlutter(dpath)

MapFiles = dir([dpath '*png'])';

revStr = '';
for m=1:length(MapFiles)
	msg = sprintf(['\n RemoveGlutter: %3.1f'], 100 * m/length(MapFiles));
	fprintf([revStr msg]);
	revStr = repmat(sprintf('\b'), 1, length(msg));

	im = im2bw(imread([dpath MapFiles(m).name]));

	%Reduce to largest connected component
	im = bwareafilt(im, 1);

        	basename = strtok(MapFiles(m).name, '.');
	imwrite([dpath basename '_llc.png'])
end
end