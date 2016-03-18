function [model, modelpath] = Train(conf)

assert(isstruct(conf))

spwd = pwd;

trainfile = [conf.name '.train'];

if exist([conf.base conf.traindir trainfile], 'file') == 2
	choice = menu('Training file found! Should I use it?', ...
		'Yes', ...
		'Recalculate', ...
		'Abort' ...
	);
else
	choice = menu('Training file not found!', ...
		'Calculate', ...
		'Abort' ...
	);
	choice = choice + 1;
end

if choice == 3
	return
end

if choice == 2
	PrepareTrain(conf)
end

cd(conf.base)
cd(conf.traindir)

[labels, instances] = libsvmread(trainfile);

cd(spwd)

choice = menu('Which classifier to use?', ...
	'LibLinear', ...
	'RandForest' ...
);

if choice == 1
	LibLinearParams = ['-s ' num2str(conf.lltype) ' -c ' num2str(conf.llc)];
	model = train(labels, instances, LibLinearParams);
	modelfile = [conf.name '_liblinear.mat'];
end

if choice == 2
	instances = full(instances);
	model = TreeBagger(conf.tbsize, instances, labels, 'Method', 'classification', 'NumPrint', 10);
	modelfile = [conf.name '_randforest.mat'];
end

cd(conf.base)
cd(conf.modeldir)
save(modelfile, 'model');
cd(spwd)

modelpath = [conf.base conf.modeldir modelfile];