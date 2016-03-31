function RemoveGlutter(dpath, type)

MapFiles = dir([dpath '*png'])';

revStr = '';
for m=1:length(MapFiles)
	msg = sprintf(['\n RemoveGlutter: %3.1f'], 100 * m/length(MapFiles));
	fprintf([revStr msg]);
	revStr = repmat(sprintf('\b'), 1, length(msg));

	im = im2bw(imread([dpath MapFiles(m).name]));

	basename = strtok(MapFiles(m).name, '.');

	if type == 0
		%Reduce to largest connected component
		im = bwareafilt(im, 1);
		imwrite(im, [dpath basename '_llc.png'])
	elseif type == 1
		%Remove small components
		im = bwareaopen(im, 50);
		imwrite(im, [dpath basename '_ao.png'])
	elseif type == 2
		%Remove everything in the top third
		im(1:size(im,1)/3, :) = 0;
		imwrite(im, [dpath basename '_cut.png'])
	end
end
end
