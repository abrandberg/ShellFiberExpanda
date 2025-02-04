function elementCoTest = importElements_v2(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as a matrix.
%   ELEMENTCOTEST = IMPORTFILE(FILENAME) Reads data from text file FILENAME
%   for the default selection.
%
%   ELEMENTCOTEST = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from
%   rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   elementCoTest = importfile('elementCoTest', 6, 153700);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2019/07/01 13:49:03

fileID0 = fopen(filename,'r');
 linecount = 0;
 tline = fgetl(fileID0);
 while ischar(tline)
   tline = fgetl(fileID0);
   linecount = linecount+1;
 end
fclose(fileID0);

%% Initialize variables.
if nargin<2
    startRow = 6;
    endRow = linecount-2; % -1 obs
elseif nargin < 3
    endRow = linecount-2; % -1 obs
end

%% Format for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
% For more information, see the TEXTSCAN documentation.
% formatSpec = '%8f%8f%8f%8f%8f%8f%[^\n\r]';
% formatSpec = '%8d%8d%8d%8d%8d%8d%[^\n\r]';
% % formatSpec = '%9f%9f%9f%9f%9f%f%[^\n\r]';
% %% Open the text file.
% fileID = fopen(filename,'r');
% %% Read columns of data according to the format.
% % This call is based on the structure of the file used to generate this
% % code. If an error occurs for a different file, try regenerating the code
% % from the Import Tool.
% dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
% for block=2:length(startRow)
%     frewind(fileID);
%     dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
%     for col=1:length(dataArray)
%         dataArray{col} = [dataArray{col};dataArrayBlock{col}];
%     end
% end

%% Close the text file.

formatSpec = '%8c%8c%8c%8c%8c%8c%[^\n\r]';
fileID = fopen(filename,'r');
d2 = textscan(fileID,formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
% dataArray = str2double( textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n'));
%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
% elementCoTest = [dataArray{1:end-1}];

collectArr = nan(size(d2{1},1),6);
% tic
for aLoop = 1:6    
   for bLoop = 1:size(d2{1},1)
       collectArr(bLoop,aLoop) = str2double(d2{1,aLoop}(bLoop,1:end));
   end
end
% toc
elementCoTest = collectArr;
