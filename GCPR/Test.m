% Test: function description
function results = Test(model, conf)

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

%Testlist-iterator
tit = 0;

results = cell([length(conf.testlists) 3]);

%Iterate over lists of test images
for testlist = conf.testlists
	tit = tit + 1;
	results(tit, 1) = {testlist{1}};
	[status, cmdout] = system(['wc -l ' conf.testbase testlist{1}]);
	if(status~=1)
		scanCell = textscan(cmdout,'%f %s');
		lineCount = scanCell{1};
	else
		error(['Could not run wc -l on ' conf.testbase testlist{1}]);
	end

	labels = zeros(lineCount, 1, 'double');
	instances = zeros(lineCount,fdims);

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

		labels(it) = comp{2};
		patch = im2single(imread([conf.testbase comp{1}]));
		instances(it, :) = GetFeatures(patch, conf.patchsize, conf.hogcellsize);
	end

	spwd = pwd;
	cd(conf.testbase)

	scores = zeros(size(labels));

	switch method
		case LibLinear
    	    instances = sparse(instances);
    	    scores = predict(labels, instances, model);
		case Randforest
    	    instances = full(instances);
    	    scores = model.predict(instances);
   		    scores = cellfun(@str2num, scores);
	end

	labels = labels - min(labels);
	scores = scores - min(scores);

	[precision, recall, ~, ~] = prec_rec(scores, labels);

	fprintf('\n-----------------------\n')
	fprintf('Precision:\t %.4f\n', precision(1))
	fprintf('Recall:\t\t %.4f\n', recall(1))
	fprintf('F-Measure:\t %.4f\n', 2*precision(1)*recall(1)/(precision(1) + recall(1)))
	fprintf('-----------------------\n')

	results(tit, 2) = {precision(1)};
	results(tit, 3) = {recall(1)};

	cd(spwd)

end
end

