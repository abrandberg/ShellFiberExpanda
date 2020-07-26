function createCFilePostProcessing_ascii(fileName,targetDir,ctrl)
% function createCFile(fileName,targetDir,physicsControl,ctrl)
% opens the d3plot file in a selected directory and writes 2 files to disk.
%
% INPUTS:   fileName            : Structure with file name pointers.
%           targetDir           : Directory where the d3plot file is
%                                 located
%           ctrl                : Structure with general control input
%
% OUTPUTS:  none
%
% I/O ACTIVITY: 
%           Write:
%           currNodes.txt       : File with the nodal coordinates in the
%                                 current (selected) configuration.
%           refElements.txt     : File with the element connectivity.
%
% 
fileID = fopen(fileName.exportLSDynaFileAscii,'w');
fprintf(fileID,'openc d3plot "%s%sd3plot"\n',targetDir,ctrl.fileSep);

% Export the ascii files
fprintf(fileID,'binaski init\n');
fprintf(fileID,'binaski load "%s%sbinout0000"\n',targetDir,ctrl.fileSep);
fprintf(fileID,'binaski fileswitch %s%sbinout0000;\n',targetDir,ctrl.fileSep);

%fprintf(fileID,)
fprintf(fileID,'binaski saveas ascii\n');
fprintf(fileID,'binaski write glstat %s\n',fileName.preStampOutputs);
fprintf(fileID,'binaski write matsum %s\n',fileName.preStampOutputs);
fprintf(fileID,'binaski write nodout %s\n',fileName.preStampOutputs);
fprintf(fileID,'binaski write nodfor %s\n',fileName.preStampOutputs);
fprintf(fileID,'binaski write rcforc %s\n',fileName.preStampOutputs);

fprintf(fileID,'exit');
fclose(fileID);
