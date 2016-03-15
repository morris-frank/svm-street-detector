% PrepareTrain: function description
function PrepareTrain(conf)

assert(isstruct(conf))

%Dimensions of the feature vector
fdims = 3 * 256 + conf.patchsize^2 * (3 * conf.hogorientations + 4);

%Load the directories with the patches
pospatches = dir([conf.base conf.positives '*png']);
lpp = length(pospatches);
negpatches = dir([conf.base conf.negatives '*png']);
lnp = length(negpatches);

%Number of testing instances
pdims = lpp + lnp;

labels = zeros(pdims, 1, 'double');
instances = sparse(pdims, fdims);

%Adding positive patches to matrix
bar = waitbar(0, [conf.name ': processing positive patches...' ]);
for i = 1:lpp
	waitbar(i/lnp)
	labels(i + lnp) = 1;
	patch = im2single(imread([conf.base conf.positives pospatches(i).name]));
	instances(i + lnp, :) = GetFeatures(...
		patch, ...
		conf.patchsize, ...
		conf.hogcellsize ...
	);
end

close(bar);

%Adding negative patches to matrix
bar = waitbar(0, [conf.name ': processing negative patches...' ]);
for i = 1:lnp
	waitbar(i/lnp)
	labels(i) = 0;
	patch = im2single(imread([conf.base conf.negatives negpatches(i).name]));
	instances(i, :) = GetFeatures(...
		patch, ...
		conf.patchsize, ...
		conf.hogcellsize ...
	);
end

close(bar);

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
