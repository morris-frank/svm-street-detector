function MODEL=TrainFromSVMFile(trainFile)

addpath('./libsvm-3.21/matlab/')

SVMParams = '-c 0.5 -g 0.0625';
[labelVec, instantMat] = libsvmread(trainFile);

MODEL = svmtrain(labelVec, instantMat, SVMParams);

end
