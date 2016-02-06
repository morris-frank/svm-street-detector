% See the file 'LICENSE' for the full license governing this code.
function MODEL = TrainFromSVMFile(trainFile, method) %#ok<*STOUT>

HeaderConfig
global LIBSVM_PATH LLC LLTYPE LLE TBSIZE
addpath(LIBSVM_PATH)

if strcmp(method, 'liblinear') == 0 && strcmp(method, 'treebagger') == 0
    error('The method has to be liblinear, treebagger.')
end
if strcmp(method, 'liblinear'); methodID = 1; end
if strcmp(method, 'treebagger'); methodID = 0; end


[~, trainFileName, ~] = fileparts(trainFile);
modelName = matlab.lang.makeValidName([trainFileName, '_', method]);

[labelVector, instanceVector] = libsvmread(trainFile); %#ok<*ASGLU>

switch methodID
	%--------------------------------------------------------
	%First case: We use the liblinear to train
	%--------------------------------------------------------    
	case 1
		LibLinearParams = ['-s ', num2str(LLTYPE), ' -c ', num2str(LLC, 3)]; %#ok<*NASGU>
		eval([modelName ' = train(labelVector, instanceVector, LibLinearParams);']);

	%--------------------------------------------------------
	%Second case: We use the TreeBagger to train
	%--------------------------------------------------------    
	case 0
		instanceVector = full(instanceVector);
	    NumPreds = num2str(floor(sqrt(size(instanceVector(1,:), 2))));
		TreeBaggerParams = ['''NumPrint'', 10'];
		eval([modelName ' = TreeBagger(TBSIZE, instanceVector, labelVector, ''Method'', ''classification'', ' TreeBaggerParams ');']);
end

eval(['save(''' modelName ''', ''' modelName ''')']);
eval(['MODEL = ' modelName ';']);

end
