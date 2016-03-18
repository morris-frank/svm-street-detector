name = 'KITTI_residential';

basedir = '~/var/data/KITTI/kitti_residential/';

testbasedir = '~/var/data/data_road/';

testfilelist = {{'training/train.txt'}};

trainfilelist = {{ ...
	'kitti0019/train.txt', ...
	'kitti0020/train.txt', ...
	%'kitti0022/train.txt', ...
	%'kitti0023/train.txt', ...
	%'kitti0035/train.txt', ...
	%'kitti0036/train.txt', ...
	%'kitti0039/train.txt', ...
	%'kitti0046/train.txt', ...
	%'kitti0061/train.txt', ...
	%'kitti0064/train.txt', ...
	%'kitti0079/train.txt', ...
	%'kitti0086/train.txt', ...
	%'kitti0087/train.txt', ...
	%'kitti1018/train.txt', ...
	%'kitti1020/train.txt', ...
	%'kitti1027/train.txt', ...
	%'kitti1028/train.txt', ...
	%'kitti1033/train.txt', ...
	%'kitti1034/train.txt', ...
	'kitti2027/train.txt', ...
	'kitti2034/train.txt' ...
}};


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

kitti_residential = ...
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