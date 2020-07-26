function writeKFile(D,outputLoc)
%writeKFile writes cell arrays to text files using a format that complies
%           with the format expected by LS-Dyna.
%
% SYNOPSIS: writeKFile(D,outputLoc)
%
% INPUT D:         Cell array with the format size(n,1) for n rows of text.
%       outputLoc: Target for the write operations (this will be the name
%                  and position of the created file.
% 
% OUTPUT: None, the file is created but no arguments are passed back.
% 
% REMARKS:
% While the function is designed for LS-Dyna .k file construction, it
% should be able to handle writing most generic input files as well.
%
% Note that the file cleans the cell array, meaning you CAN supply arrays
% with empty rows and the function will remove them, but you CANNOT submit
% cell arrays with intentionally blank rows.
%
% TO DO:
% - Pass success/failure status of file creation.
% - Switch cleaning/no cleaning of cell array to make more general.
% 
% created by: August Brandberg
% DATE: 19-03-2017
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% empties = find(cellfun(@isempty,D));                                        % identify the empty cells
% D(empties) = [];                                                            % remove the empty cells

fileID = fopen(outputLoc,'w');
% for mLoop=1:size(D,1)
%     if size(deblank(D{mLoop}),2) == 80
%         fprintf(fileID,'%80s \n',D{mLoop});
%     else
        fprintf(fileID,'%s \n',D{:});
%     end
% end
fclose(fileID);









