function MODEL = TrainFromSVMFile(trainFile, method)

HeaderConfig
global LIBSVM_PATH
addpath(LIBSVM_PATH)

if strcmp(method, 'liblinear') == 0 && strcmp(method, 'treebagger') == 0
    error('The method has to be liblinear, treebagger.')
end
if strcmp(method, 'liblinear'); methodID = 1; end
if strcmp(method, 'treebagger'); methodID = 0; end


[~, trainFileName, ~] = fileparts(trainFile);
modelName = genvarname([trainFileName, '_', method]);

[labelVector, instanceVector] = libsvmread(trainFile);

%--------------------------------------------------------
%First case: We use the liblinear to train
%--------------------------------------------------------    
if methodID == 1
	global LLC LLTYPE LLE
	LibLinearParams = ['-s ', num2str(LLTYPE), ' -c ', num2str(LLC, 3)];
	eval([modelName ' = train(labelVector, instanceVector, LibLinearParams);']);
end

%--------------------------------------------------------
%Second case: We use the TreeBagger to train
%--------------------------------------------------------    
if methodID == 0
	global TBSIZE
	instanceVector = full(instanceVector);
	TreeBaggerParams = ['''NumPrint'', 20, ''NumPredictorsToSample'', ' TBNUMPREDS];
	eval([modelName ' = TreeBagger(TBSIZE, instanceVector, labelVector, ''Method'', ''classification'', ' TreeBaggerParams ');']);
end

eval(['save(''' modelName ''', ''' modelName ''')']);
eval(['MODEL = ' modelName] ';');

end
