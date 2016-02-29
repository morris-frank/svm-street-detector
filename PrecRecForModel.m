% See the file 'LICENSE' for the full license governing this code.
function scores = PrecRecForModel(trainFile, Model, ModelType)

HeaderConfig
global LIBSVM_PATH DATAFOLDER

addpath(LIBSVM_PATH)

assert(ModelType == 0 || ModelType == 1)

[labels, instances] = libsvmread(trainFile); %#ok<*ASGLU>
size(labels)
scores=zeros(size(labels));

disp(['Predicting for ...'])
switch ModelType
    case 1
        instances = sparse(instances);
        scores = predict(labels, instances, Model);
    case 0
        instances = full(instances);
        scores = Model.predict(instances);
        scores = cellfun(@str2num, scores);
end

[precision, recall, ~, ~] = prec_rec(scores, labels);

disp('Precision:')
disp(precision(1))
disp('Recall:')
disp(recall(1))
disp('F-Measure:')
disp(2*precision(1)*recall(1)/(precision(1) + recall(1)))
