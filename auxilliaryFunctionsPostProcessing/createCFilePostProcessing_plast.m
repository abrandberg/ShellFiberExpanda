function savePath = createCFilePostProcessing_plast(fileName,targetDir,loopMax,ctrl)
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
fileID = fopen(fileName.exportLSDynaFilePlast,'w');
fprintf(fileID,'openc d3plot "%s%sd3plot"\n',targetDir,ctrl.fileSep);
fprintf(fileID,'selectpart solid off;\n'); % Turn off any solid parts
% fprintf(fileID,'output append 1\n');
fprintf(fileID,'output %s %d 1 0 1 0 0 0 0 0 0 0 0 0 1 0 1.000000\n',horzcat('"',targetDir,ctrl.fileSep,'eVolumes.txt"'),1);
% fprintf(fileID,'output %s %d 1 1 0 1 0 0 0 0 0 0 0 0 0 1 0 1.000000\n',horzcat('"',targetDir,ctrl.fileSep,'eVolumes.txt"'),1)
%                              1 1 0 1 0 0 0 0 0 0 0 0 0 1 0 1.000000
for aLoop = 1:loopMax
%     fprintf(fileID,'output %s %d 1 4 0 1 0 0\n',horzcat('"',targetDir,ctrl.fileSep,'currEps_',num2str(aLoop),'.txt"'),aLoop);
    fprintf(fileID,'output %s %d 4 0 1 0 0\n',horzcat('"',targetDir,ctrl.fileSep,'currEps_',num2str(aLoop),'.txt"'),aLoop);
    savePath{aLoop,1} = horzcat('"',targetDir,ctrl.fileSep,'currEps_',num2str(aLoop),'.txt"');
    
end
fprintf(fileID,'exit');
fclose(fileID);

