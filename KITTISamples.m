function KITTISamples(trainings_dir)
	MapFiles = dir([trainings_dir '/maps/*png'])';
    
    bar = waitbar(0, 'Generating patches...');
	for m = 1:length(MapFiles)    
        waitbar(m/length(MapFiles))
		hm = imread([trainings_dir '/maps/' MapFiles(m).name]);
        im = imread([trainings_dir '/image/' MapFiles(m).name]);
        hm = im2bw(hm, 0.4);
        basename = strtok(MapFiles(m).name, '.');
        SampleHM(im, hm, [trainings_dir '/patches/'], basename);
    end
    close(bar)
end