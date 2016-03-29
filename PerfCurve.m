function [X,Y,T,AUC,OPTROCPT] = PerfCurve(gnddir, scrdir)

GndFiles = dir([gnddir '/*png'])';

labels = [];
scores =[];
posclass = 1;

CntGnd = length(GndFiles);

revStr = '';
for m=1:110
    msg = sprintf(['\nPerfCurve : %3.1f'], 100 * m/CntGnd);
    fprintf([revStr msg]);
    revStr = repmat(sprintf('\b'), 1, length(msg));

	gnd = imread([gnddir GndFiles(m).name]);
	scr = imread([scrdir GndFiles(m).name]);

    gnd1 = im2bw(gnd, 0.4);
    gnd2 = imcomplement(im2bw(gnd, 0.2));

    gnd = gnd1 + gnd2;
    gnd = logical(gnd);
    
    scr = im2single(scr);
    clear gnd1 gnd2

	labels = [labels; gnd(:)];
	scores = [scores; scr(:)];
end

[X,Y,T,AUC,OPTROCPT] = perfcurve(labels,scores,posclass);

plot(X,Y)
hold on
plot(OPTROCPT(1), OPTROCPT(2), 'ro')
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC Curve')
hold off