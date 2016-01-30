function PredictFrameForAllModels(FolderPath, FolderName, f, permut, modus)
%Classify the contents of a Frame for all Models in the current dir
%PredictFrameForAllModels(FolderName, FrameID)

if nargin < 4
	permut = 0;
    if nargin < 5
        modus = 'pos';
    end
end

if strcmp(modus, 'pos') == 0 && strcmp(modus, 'neg') == 0
    error('The modus has to be pos, neg.')
end
if strcmp(modus, 'pos'); modus = 1; end
if strcmp(modus, 'neg'); modus = 0; end

for file = dir(FolderPath)'

	%If name is too short we can already jump to the next one
	if length(file.('name')) < 4; continue; end

	%If the file extension is not mat we can continue
	if strcmp(file.('name')(end-3:end), '.mat') == 0; continue; end

	%We assume here that all .mat files are models

	loaded = load(file.('name'));
	SNames = fieldnames(loaded);
	Model = getfield(loaded, SNames{1});

	disp(['Run with model: ' SNames{1}])
    figure('Name', [SNames{1}], 'WindowStyle', 'docked', 'NumberTitle', 'Off');
	PredictFrame(FolderName, f, Model, permut, modus)

end