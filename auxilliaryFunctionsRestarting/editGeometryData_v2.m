function filemod = editGeometryData_v2(targetDir,ctrl,fileName,keycardsToDelete)
% function editGeometryData(targetDir,ctrl,fileName) reads in a file
% containing LSDyna geometry data (nodal, element, part and section data)
% and then performs a series of operations to prepare the restart
% simulation.
%
% INPUTS:   targetDir           : Directory containing the file
%           ctrl                : General control information
%           fileName            : Structure containing file names
%
% OUTPUTS:  filemod             : The edited geometry data in cell format
%                                 where each row is a cell. 
%
%
disp(['-----> Removing keycards in ', fileName])
tic

% Read the geometry file from the compression load step
fileID = fopen(horzcat(targetDir,ctrl.fileSep,fileName));
filemod = textscan(fileID,'%s','delimiter','\n','whitespace', '');
fclose(fileID);
filemod = filemod{1,1};


% Find all the keywords and their positions
startIndex = regexp(filemod,'*');
tf = cellfun('isempty',startIndex);         % true for empty cells
startIndex(tf) = {0};                       % replace by a cell with a zero 
startIndex = cell2mat(startIndex);
[pk,~] = find(startIndex);

% Find the *NODE and *ELEMENT_SOLID keycard
% keycardsToDelete = {'*ELEMENT_SOLID';'*ELEMENT_SHELL';'*NODE'};

deleteList = [];
for aLoop = 1:numel(keycardsToDelete)
    idxToDelete = contains(filemod(pk),keycardsToDelete{aLoop});
    startIdx = pk(find(idxToDelete));
    endIdx = pk(find([0 ; idxToDelete(1:end-1)]))-1;
    deleteList = [deleteList ; [startIdx:endIdx]'];
end

filemod(deleteList) = [];

toc

