function ProcessVideosBBFiles(FolderNumbers)

HeaderConfig
global FOLDERNAMEBASE

%Get the current parallel loop
p = gcp();

%Iterate through video folders
parfor f = 1:length(FolderNumbers)
	FolderNumber = FolderNumbers(f);
    SeqFolderName = [FOLDERNAMEBASE, sprintf('%04d', FolderNumber)];

    ProcessBBFile([SeqFolderName '.bb'], SeqFolderName)
end

end