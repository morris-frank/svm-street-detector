function MODEL=TrainFromSVMFile(trainFile)

HeaderConfig
global LIBSVM_PATH
addpath(LIBSVM_PATH)

SVMParams = '-c 0.5 -g 0.0625';
[labelVec, instantMat] = libsvmread(trainFile);

MODEL = svmtrain(labelVec, instantMat, SVMParams);

end
