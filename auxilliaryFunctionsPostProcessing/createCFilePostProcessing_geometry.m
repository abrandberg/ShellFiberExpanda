function savePath = createCFilePostProcessing_geometry(fileName,targetDir,loopMax,ctrl)
% function createCFile(fileName,targetDir,physicsControl,ctrl)
% opens the d3plot file in a selected directory and writes 2 files to disk.
%
% INPUTS:   fileName            : Structure with file name pointers.
%           targetDir           : Directory where the d3plot file is
%                                 located
%           physicsControl      : Structure with physics data for the
%                                 restart simulation
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
fileID = fopen(fileName.exportLSDynaFileGeometry,'w');
fprintf(fileID,'openc d3plot "%s%sd3plot"\n',targetDir,ctrl.fileSep);
fprintf(fileID,'output %s %d 1 0 1 1 0 0 0 0 0 0 0 0 0 0 1.000000\n',horzcat('"',targetDir,ctrl.fileSep,'refElements.txt"'),1);
for aLoop = 1:loopMax
   %
    fprintf(fileID,'output %s %d 1 0 1 0 1 0 0 0 0 0 0 0 0 0 1.000000\n',horzcat('"',targetDir,ctrl.fileSep,'currNodes_',num2str(aLoop),'.txt"'),aLoop);
    
    savePath{aLoop,1} = horzcat('"',targetDir,ctrl.fileSep,'currNodes_',num2str(aLoop),'.txt"');
    
end
fprintf(fileID,'exit');
fclose(fileID);
