% Test: function description
function  PredictTestDir(model, conf)

LibLinear = 1;
Randforest = 0;

% Model is LibLinear
if isstruct(model)
    method = LibLinear;
% Model is Randforest
elseif isobject(model)
    method = Randforest;
end

%If only on path is given
if ~iscellstr(conf.testlists) and ischar(conf.testlists)
	conf.testlists = cellstr(conf.testlists);
end

assert(isstruct(conf))
assert(iscellstr(conf.testlists))

%Dimensions of the feature vector
fdims = 3 * 256 + conf.patchsize^2 * (3 * conf.hogorientations + 4);

%Iterate over lists of test images
for testlist = conf.testlists
	[status, cmdout] = system(['wc -l ' conf.testbase testlist{1}]);
	if(status~=1)
		scanCell = textscan(cmdout,'%f %s');
		lineCount = scanCell{1};
	else
		error(['Could not run wc -l on ' conf.testbase testlist{1}]);
	end

	fid = fopen([conf.testbase testlist{1}], 'rt');

	revStr = '';
	for it=1:lineCount
		msg = sprintf(['\n' testlist{1} ': %3.1f'], 100 * it/lineCount);
		fprintf([revStr msg]);
		revStr = repmat(sprintf('\b'), 1, length(msg));
		tl = fgetl(fid);
		if ~ischar(tl)
			break
		end

		comp = strsplit(tl);
		name = strsplit(comp{1}, '/');

		[hm im] = PredictFrame(model, conf, [conf.testbase comp{1}]);

		imwrite(hm, [conf.testbase 'training/predictions/' name{3}])
	end

end
end

