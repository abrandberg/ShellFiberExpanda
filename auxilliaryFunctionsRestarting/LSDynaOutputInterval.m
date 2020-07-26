function LSDynaOutputInterval(databaseFile,outputFile,ctime)
%function LSDynaOutputInterval(databaseFile,outputFile,ctime) edits 
%the predefined settings to get a reasonable number of outputs.
%
% INPUT:    See the networkGeneration.m file for documentation
%           of the inputs.
%
% OUTPUT:   A file with database output settings which will be
%           called by the main .K file.
%
% created by: August Brandberg
% date: 2020-07-24
fileID = fopen(databaseFile,'r');
dbText = fread(fileID,'*char');
fclose(fileID);

dbText_mod = strrep(dbText', '1.3333e-08', num2str(ctime/150));
dbText_mod = dbText_mod';

fileID = fopen(outputFile,'w');
fprintf(fileID,'%s\n',dbText_mod);
fclose(fileID);
