name = 'KITTI_data_road';

basedir = '~/var/data/KITTI/data_road/';

testbasedir = '~/var/data/KITTI/data_road/';

testfilelist = {{'training/train.txt'}};

trainfilelist = {{'training/train.txt'}};

modeldir = '../';
traindir = '../';

%----------

%Feature options
hogcellsize = 17;
hogorient = 9;
patchsize = 3;

%LibLinear options
lltype = 2;
llc = 1e2;

%Randforest options
tbsize = 30;

kitti_data_road = ...
	struct('name', name, ...
		   'base', basedir, ...
		   'testbase', testbasedir, ...
		   'modeldir', modeldir, ...
		   'traindir', traindir, ...
		   'hogcellsize', hogcellsize, ...
		   'hogorientations', hogorient, ...
		   'patchsize', patchsize, ...
		   'lltype', lltype, ...
		   'llc', llc, ...
		   'tbsize', tbsize, ...
		   'trainlists', trainfilelist, ...
		   'testlists', testfilelist ...
		  );


clear name basedir testimgdir modeldir traindir
clear hogcellsize hogorient patchsize lltype llc tbsize trainfilelist