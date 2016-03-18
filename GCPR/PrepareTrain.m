% PrepareTrain: function description
function PrepareTrain(conf)

%If only on path is given
if ~iscellstr(conf.trainlists) and ischar(conf.trainlists)
	conf.trainlists = cellstr(conf.trainlists);
end

assert(isstruct(conf))
assert(iscellstr(conf.trainlists))

%Dimensions of the feature vector
fdims = 3 * 256 + conf.patchsize^2 * (3 * conf.hogorientations + 4);

labels = zeros(0, 1, 'double');
instances = sparse(0,fdims);

startit = 0;

%Iterate over lists of trainings images
for trainlist = conf.trainlists
	[status, cmdout] = system(['wc -l ' conf.base trainlist{1}]);
	if(status~=1)
		scanCell = textscan(cmdout,'%f %s');
		lineCount = scanCell{1};
	else
		error(['Could not run wc -l on ' conf.base trainlist{1}]);
	end

	labels = padarray(labels, lineCount, 'post');
	instances = sparse(padarray(instances, [lineCount 0], 'post'));

	fid = fopen([conf.base trainlist{1}], 'rt');


	bar = waitbar(0, [trainlist{1} ': processing file...' ]);
	for it=1:lineCount
		waitbar(it/lineCount)
		tl = fgetl(fid);
		if ~ischar(tl)
			break
		end

		comp = strsplit(tl);

		labels(it + startit) = comp{2};
		patch = im2single(imread([conf.base comp{1}]));
		instances(it + startit, :) = GetFeatures(...
			patch, ...
			conf.patchsize, ...
			conf.hogcellsize ...
		);
	end

	startit = it;
	close(bar);
end

spwd = pwd;
cd(conf.base)
cd(conf.traindir)

libsvmwrite(...
	[conf.name '.train'], ...
	sparse(labels), ...
	instances ...
);

cd(spwd)

end
