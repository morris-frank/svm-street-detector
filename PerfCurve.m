function [X,Y,T,AUC,OPTROCPT] = PerfCurve(gnddir, scrdir)

GndFiles = dir([gndir '/*png'])';

labels = [];
scores =[];
posclass = 1;

bar = waitbar(0, 'Generating patches...');
for m = 1:length(GndFiles)
        	waitbar(m/length(GndFiles))
	gnd = imread([gndir GndFiles(m).name]);
	scr = imread([scrdir GndFiles(m).name]);

	labels = [labels; gnd(:)];
	scores = [scores; scr(:)];
end
close(bar)

[X,Y,T,AUC,OPTROCPT] = perfcurve(labels,scores,posclass);