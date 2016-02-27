% See the file 'LICENSE' for the full license governing this code.
function MODEL = TrainFromSVMFile(trainFile, method) %#ok<*STOUT>

HeaderConfig
global LIBSVM_PATH LLC LLTYPE LLE TBSIZE DATAFOLDER
addpath(LIBSVM_PATH)

if strcmp(method, 'linear') == 0 && strcmp(method, 'randforest') == 0
    error('The method has to be linear, randforest.')
end
if strcmp(method, 'linear'); methodID = 1; end
if strcmp(method, 'randforest'); methodID = 0; end


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
	%Second case: We use the randforest to train
	%--------------------------------------------------------
	case 0
		instanceVector = full(instanceVector);
	    NumPreds = num2str(floor(sqrt(size(instanceVector(1,:), 2))));
		randforestParams = ['''NumPrint'', 10'];
		eval([modelName ' = TreeBagger(TBSIZE, instanceVector, labelVector, ''Method'', ''classification'', ' randforestParams ');']);
end

eval(['save(''' modelName ''', ''' modelName ''')']);
%eval(['movefile(''' modelName '.mat'', ''' DATAFOLDER 'MODEL/'''])
%eval(['MODEL = ' modelName ';']);

end
