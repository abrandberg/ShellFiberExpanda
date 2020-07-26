%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restarting procedure for LS-Dyna shell model
%
% This restart script applies boundary conditions to the nodes directly, 
% which is appropriate for tensile tests. By reverting the load direction,
% it is also possible to test in compression.
%
% The fiber-to-fiber interaction is determined via tied contacts, which is 
% probably not the best way but it is implemented like that for historical
% reasons.
%
%
% created by: August Brandberg august at kth . se
% date: 04-11-2019
%

% Initialize everything
clear; clc
format compact
workingDir = cd;
rmpath(fullfile(workingDir,'auxilliaryFunctionsGeneration'));
addpath(fullfile(workingDir,'auxilliaryFunctionsRestarting'));

if ispc
    ctrl.fileSep = '\';
    ctrl.execEnvir = 'Windows';
    nameOfHost = getenv('computername');
else
    ctrl.fileSep = '/';
    ctrl.execEnvir = 'Linux';
    nameOfHost = getenv('HOSTNAME');
end

% File and directory pointers
targetDir = '/scratch/users/august/ExpandaPaper/versionControlled/ShellFiberExpanda/initialCommit_AB_2020-07-23/uncompressed_date_24-Jul-2020'

switch nameOfHost
    case 'AUGUSTBR-DATOR'       % work computer (August)
        lsprepostInstallation = '"C:\Program Files\LSTC\LS-PrePost 4.3\lsprepost4.3_x64.exe"';
    case 'LAPTOP-IPMEKGCS'      % laptop (August)
        lsprepostInstallation = '"C:\Program Files\LSTC\LS-PrePost 4.5\lsprepost4.5_x64.exe"';
    case 'HALLF-SUPER1'         % Windows machine
        lsprepostInstallation = '"C:\Program Files\LSTC\LS-PrePost 4.3\lsprepost4.3_x64.exe"';
    case 'DESKTOP-IVRK4E8'
        lsprepostInstallation = '"C:\Program Files\LSTC\LS-PrePost 4.7\lsprepost4.7_x64.exe"';
    case 'bertil.hallf.kth.se'
        lsprepostInstallation = '/usr/lsdyna/lsprepost4.7_sles12/lspp47';
    otherwise % 'b-an01.hpc2n.umu.se'
        lsprepostInstallation = '/usr/lsdyna/lsprepost4.7_sles12/lspp47';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name convention and paths
% The fileName structure contains all necessary file name pointers.
% fileName.mainCard             : Name of the new main file for the sim
%         .boundaryFile         : File with boundary condtions
%         .databaseCard         : File controlling result output frequency
%         .exeFile              : File to be submitted to QSUB or SBATCH
%         .geometryFile         : File with nodal, element, part, section
%                                 data for the model
%         .outputFile           : File to write output of simulation
fileName.boundaryFile     = 'boundaryConditionsRestart.k';
fileName.databaseCard     = 'Database_output_for_explicit.k';
fileName.exeFile          = 'submissionFile.sh';
fileName.exportLSDynaFile = 'cFile.dat';
fileName.geometryFile     = 'file.k';
fileName.mainCard         = 'Main_card_v8_restart.k';
fileName.outputFile       = 'outputScreen.txt';
fileName.statsNetworkFile = 'statisticsRestart.csv';
fileName.restartElements  = 'rElementsRestart.txt';
fileName.restartNodes     = 'cNodesRestart.txt';
fileName.cFileName        = 'test1.dat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execution information
% The exeInformation structure contains pointers for the creation of a
% submit file on the clusters.
% exeInformation.exeFileName    : Submission file name
%               .np             : Number of processors to use
%               .mainCardFile   : Name of the new main file for the sim
%               .outputFile     : File name for output text
%               .exeEnvironment : Cluster on which to run:
%                                   - 'bertil'
%                                   - 'burster'
%                                   - 'tensor'
%               .computeTime    : Time to reserve on the cluster (KB only)
exeInformation.exeFileName    = fileName.exeFile;
exeInformation.np             = 24;
exeInformation.mainCardFile   = fileName.mainCard;
exeInformation.outputFile     = fileName.outputFile;
exeInformation.exeEnvironment = 'bertil';
exeInformation.computeTime    = '00-23:00:00';




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Physics description
% The physicsControl structure contains information about boundary
% conditions.
% physicsControl.restartStep    : Output step at which to restart
%               .solTime        : Solution time
%               .minEdge        : 
%               .maxEdge        : 
physicsControl.restartStep = 2;%164; %25
physicsControl.solTime = 2*1.5e-5;
physicsControl.MinEdge         = 1400;
physicsControl.MaxEdge         = 4600;
physicsControl.appliedStrain   = -0.15;


nameString = strcat('restart_',datestr(now,'yyyymmddTHHMMSS'));              % Name of new folder containing restart data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a directory to be used for the restart simulation
%
% Files in a finished folder:
%   1. Database_output_for_explicit.k
%   2. file.k
%   3. Main_card_v8.k
destinationString = strcat(targetDir,ctrl.fileSep,nameString);
mkdir(horzcat(targetDir,ctrl.fileSep,nameString)) 
LSDynaOutputInterval(horzcat(targetDir,ctrl.fileSep,fileName.databaseCard),fileName.databaseCard,physicsControl.solTime);
movefile(fileName.databaseCard,strcat(destinationString,ctrl.fileSep,fileName.databaseCard))
copyfile(horzcat(targetDir,ctrl.fileSep,fileName.geometryFile)             ,strcat(destinationString,ctrl.fileSep,fileName.geometryFile ))
copyfile(horzcat(targetDir,ctrl.fileSep,'Main_card_v8.k')     ,strcat(destinationString,ctrl.fileSep,'Main_card_v8.k' ))


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a new submission file for the restart script
createSubmissionScript(exeInformation);
movefile(exeInformation.exeFileName,strcat(destinationString,ctrl.fileSep,exeInformation.exeFileName))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Export nodal and element data from the compression stage.
%
% This part handles the finding of the lsprepost executable and the
% submission of our custom script. The script needs to be updated to point
% to :
% - the right executable
% - the right target directory
createCFile(fileName,targetDir,physicsControl,ctrl)
movefile(fileName.exportLSDynaFile,strcat(destinationString,ctrl.fileSep,fileName.exportLSDynaFile))

extractionFile = horzcat(destinationString,ctrl.fileSep,fileName.exportLSDynaFile);
system(horzcat(lsprepostInstallation,' c=',extractionFile))

% Move output to the restart directory.
movefile(horzcat(targetDir,ctrl.fileSep,fileName.restartNodes),  horzcat(destinationString,ctrl.fileSep,fileName.restartNodes))
movefile(horzcat(targetDir,ctrl.fileSep,fileName.restartElements),horzcat(destinationString,ctrl.fileSep,fileName.restartElements))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import nodes and re-cut, then write to file again.
% Import elements.
% First step: Write the new bounding box to be used
xRange = [physicsControl.MinEdge-200 physicsControl.MaxEdge+200];
zRange = [physicsControl.MinEdge-200 physicsControl.MaxEdge+200];

maxElFib = recutNetwork_v2(horzcat(destinationString,ctrl.fileSep,fileName.restartNodes),horzcat(destinationString,ctrl.fileSep,fileName.restartElements),xRange,zRange);

filemod =editGeometryData(targetDir,ctrl,fileName);

keycardsToDelete = {'*ELEMENT_SOLID'};
restartElementsTemp =editGeometryData_v2(destinationString,ctrl,fileName.restartElements,keycardsToDelete);

writeKFile(restartElementsTemp,fileName.restartElements);
movefile(fileName.restartElements,horzcat(destinationString,ctrl.fileSep,fileName.restartElements))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update the geometry file
%
% The function replaceLSDYNA.m is used when we know how many lines we would 
% like to remove.
disp('-> UPDATING CONTROL CARDS')
changeStructure(1).CriterionCurrent  = '*BOUNDARY_PRESCRIBED_MOTION_RIGID';
changeStructure(1).CriterionPrevious = '';
changeStructure(1).CriterionNext     = '';
changeStructure(1).InstructionType   = 'delete';
changeStructure(1).DeleteLines       = 2;

changeStructure(2).CriterionCurrent  = '*DEFINE_CURVE';
changeStructure(2).InstructionType   = 'delete';
changeStructure(2).DeleteLines       = 10; % 8 usually

changeStructure(3).CriterionCurrent  = '*SECTION_SOLID';
changeStructure(3).InstructionType   = 'delete';
changeStructure(3).DeleteLines       = 2;

changeStructure(4).CriterionCurrent  = '*CONTROL_TERMINATION';
changeStructure(4).InstructionType   = 'delete';
changeStructure(4).DeleteLines       = 2;

changeStructure(5).CriterionCurrent  = '*PART';
changeStructure(5).CriterionNext     = 'Part        2 for Mat        2 and Elem Type        2';
changeStructure(5).InstructionType   = 'delete';
changeStructure(5).DeleteLines       = 3;

changeStructure(6).CriterionCurrent  = '*DATABASE_HISTORY_NODE';
changeStructure(6).InstructionType   = 'delete';
changeStructure(6).DeleteLines       = 2;

changeStructure(7).CriterionCurrent  = '*PART';
changeStructure(7).CriterionNext     = 'Part        3 for Mat        2 and Elem Type        2';
changeStructure(7).InstructionType   = 'delete';
changeStructure(7).DeleteLines       = 3 ;

changeStructure(8).CriterionCurrent  = '*CONTACT_AUTOMATIC_GENERAL';
changeStructure(8).InstructionType   = 'delete';
changeStructure(8).DeleteLines       = 4;

C = replaceLSDYNA(filemod,changeStructure);

% At this point we can write the data to file again.
writeKFile(C,'file_restart.k');
movefile('file_restart.k',horzcat(destinationString,ctrl.fileSep,'file_restart.k'))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE MAIN KEY FILE
%
clear changeStructure
fileID = fopen(horzcat(targetDir,ctrl.fileSep,'Main_card_v8.k'));
B = textscan(fileID,'%s','delimiter','\n','whitespace', '');
fclose(fileID);
B = B{1,1};

changeStructure(1).CriterionCurrent  = '*INCLUDE';
changeStructure(1).CriterionPrevious = '';
changeStructure(1).CriterionNext     = 'file.k';
changeStructure(1).InstructionType   = 'replace';
changeStructure(1).Instruction       = {'*INCLUDE' , ...
                                        fileName.restartNodes, ...  
                                        '*INCLUDE' , ...
                                        fileName.restartElements, ...  
                                        '*INCLUDE', ...
                                        'file_restart.k' , ...
                                        '*INCLUDE' , ...
                                        'boundaryConditionsRestart.k' , ...
                                        '*INCLUDE', ...
                                        'contactCardRestart.k'};
changeStructure(1).DeleteLines       = 2;

changeStructure(2).CriterionCurrent  = '*MAT_PLASTIC_KINEMATIC';
changeStructure(2).InstructionType   = 'replace';
changeStructure(2).Instruction       = {'*MAT_PLASTIC_KINEMATIC' , ...
                                        '         1 1.000E-15 0.750E+04  0.200000 0.270E+03 0.450E+02  1.00'};
changeStructure(2).DeleteLines       = 2;

changeStructure(3).CriterionCurrent  = '*DAMPING_GLOBAL';
changeStructure(3).InstructionType   = 'replace';
changeStructure(3).Instruction       = {'*DAMPING_GLOBAL', ...
                                        '           1.5E2'};
changeStructure(3).DeleteLines       = 2;

changeStructure(4).CriterionCurrent  = '*CONTACT_FORCE_TRANSDUCER';
changeStructure(4).InstructionType   = 'delete';
changeStructure(4).DeleteLines       = 5;

changeStructure(5).CriterionCurrent  = '$#  slsfac    rwpnal    islchk    shlthk    penopt    thkchg     orien    enmass ';
changeStructure(5).InstructionType   = 'replace';
changeStructure(5).Instruction       = {'$#  slsfac    rwpnal    islchk    shlthk    penopt    thkchg     orien    enmass ', ...
                                       '  0.100000     0.000         1         1         0         0         1         0'};
changeStructure(5).DeleteLines       = 2;

changeStructure(6).CriterionCurrent  = '*END';
changeStructure(6).InstructionType   = 'replace';
changeStructure(6).Instruction       = {'*DATABASE_NODAL_FORCE_GROUP', ...
                                       '$#    nsid        cid', ...
                                       '     10001', ...
                                       '*END' ...
                                       '*DATABASE_NODAL_FORCE_GROUP', ...
                                       '$#    nsid        cid', ...
                                       '     10002', ...
                                       '*END'};
changeStructure(6).DeleteLines       = 1;
  
B = replaceLSDYNA(B,changeStructure);
writeKFile(B,'Main_card_v8_restart.k')
movefile('Main_card_v8_restart.k',horzcat(destinationString,ctrl.fileSep,'Main_card_v8_restart.k'))



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORT ELEMENTS 
%
% Next step is to import the elements into the model so that we can update
% the contact formulations. We use a cohesive relation.
disp('-> IMPORTING ELEMENTS')
elementsInModel = importElements_v2(horzcat(destinationString,ctrl.fileSep,fileName.restartElements));

disp('-> IMPORTING NODAL POSITIONS')
nodalCurrentPositions = importNode(horzcat(destinationString,ctrl.fileSep,fileName.restartNodes)); 

partListOld = createPartStructure(nodalCurrentPositions,elementsInModel);
partList = contactFormulationShellRestart_v2(partListOld,elementsInModel);
writeContactCard(elementsInModel,partList,'contactCardRestart.k')
movefile('contactCardRestart.k',horzcat(destinationString,ctrl.fileSep,'contactCardRestart.k'))



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEFT AND RIGHT BOUNDARY METHOD
%
% NETWORK:
%           --------------------
%          |xxx              xxx|
%   F<---  |xxx              xxx|  --->F
%          |xxx              xxx|
%           --------------------
%              |            |
%          xMinEdge     xMaxEdge
%
% x indicates nodes on which we enforce displacement.
%
% We will use a single file to store all of the boundary conditions. The
% boundary conditions have the following basic check list:
% 
% INPUTS: 1. A set of nodes onto which the boundary conditions are to be
%            applied.
%         2. An axis along which the boundary condition is to be applied.
%         3. A flag for the type of boundary condition to be applied
%           (displacement, velocity or acceleration to begin with).
%         4. The end time of the simulation.
%         5. The inline function which should be used to form the curve.
%         6. The number of points which should be used to form the curve.
%         7. A file onto which the results should be appended.
disp('-> GENERATING BOUNDARY SETS AND LOAD CASE')
nodesToTrack(1) = nodalCurrentPositions(find(nodalCurrentPositions(:,1+1)<physicsControl.MinEdge,1),1); % +3
nodesToTrack(2) = nodalCurrentPositions(find(nodalCurrentPositions(:,1+1)>physicsControl.MaxEdge,1),1);

boundaryControl(1).loadAxis = 1;
boundaryControl(1).loadType = 0;%2;
boundaryControl(1).nodeSet = nodalCurrentPositions(nodalCurrentPositions(:,1+1)<physicsControl.MinEdge,:);
boundaryControl(1).fcnCurve = @(t) 4e3*physicsControl.appliedStrain.*t./physicsControl.solTime^2; %0;%
boundaryControl(1).fcnDisc = 4;

boundaryControl(2).loadAxis = 2;
boundaryControl(2).loadType = 2;
boundaryControl(2).nodeSet = nodalCurrentPositions(nodalCurrentPositions(:,1+1)<physicsControl.MinEdge,:);
boundaryControl(2).fcnCurve = @(t) 0;
boundaryControl(2).fcnDisc = 4;

boundaryControl(3).loadAxis = 3;
boundaryControl(3).loadType = 2;
boundaryControl(3).nodeSet = nodalCurrentPositions(nodalCurrentPositions(:,1+1)<physicsControl.MinEdge,:);
boundaryControl(3).fcnCurve = @(t) 0;
boundaryControl(3).fcnDisc = 4;

boundaryControl(4).loadAxis = 1;
boundaryControl(4).loadType = 2;
boundaryControl(4).nodeSet = nodalCurrentPositions(nodalCurrentPositions(:,1+1)>physicsControl.MaxEdge,:);
boundaryControl(4).fcnCurve = @(t) 0;
boundaryControl(4).fcnDisc = 4;

boundaryControl(5).loadAxis = 2;
boundaryControl(5).loadType = 2;
boundaryControl(5).nodeSet = nodalCurrentPositions(nodalCurrentPositions(:,1+1)>physicsControl.MaxEdge,:);
boundaryControl(5).fcnCurve = @(t) 0;
boundaryControl(5).fcnDisc = 4;

boundaryControl(6).loadAxis = 3;
boundaryControl(6).loadType = 2;%0;
boundaryControl(6).nodeSet = nodalCurrentPositions(nodalCurrentPositions(:,1+1)>physicsControl.MaxEdge,:);
boundaryControl(6).fcnCurve = @(t) 0;%-4e3*physicsControl.appliedStrain.*t./physicsControl.solTime^2;%0;
boundaryControl(6).fcnDisc = 4;

boundaryConditionsRestart_v2(boundaryControl,physicsControl,fileName)



fileID = fopen(fileName.boundaryFile,'a');
fprintf(fileID,'%s\n','*DATABASE_HISTORY_NODE');
fprintf(fileID,'%10d%10d\n',nodesToTrack(1),nodesToTrack(2));
fclose(fileID);

movefile('boundaryConditionsRestart.k',horzcat(destinationString,ctrl.fileSep,'boundaryConditionsRestart.k'))



cd(workingDir)
fileID = fopen(fileName.statsNetworkFile,'w');
fprintf(fileID,'%s\n','Restart summary');
fprintf(fileID,'%s\n','');
fprintf(fileID,'%s\n','Environment information');
fprintf(fileID,'%s\n','');

fprintf(fileID,'File generated                %s\n',datestr(now));
fprintf(fileID,'Computer architecture         %s\n',computer('arch'));
fprintf(fileID,'MATLAB version                %s\n',version);
fprintf(fileID,'Computer name was reported as %s\n',nameOfHost);

fprintf(fileID,'%s\n','');
fprintf(fileID,'%s\n','Load information');
fprintf(fileID,'Restarting from step : %d\n',physicsControl.restartStep);
fprintf(fileID,'Applied strain = %10.4f\n',physicsControl.appliedStrain);
fprintf(fileID,'MinEdge = %10.4f um\n',physicsControl.MinEdge);
fprintf(fileID,'MaxEdge = %10.4f um\n',physicsControl.MaxEdge);
fprintf(fileID,'Solution time = %10.4e\n',physicsControl.solTime);
fclose(fileID);

movefile(fileName.statsNetworkFile,strcat(destinationString,ctrl.fileSep,fileName.statsNetworkFile))

if 1
    disp('-> Submitting job')
    disp('   To open, restart directory is:')
    disp(destinationString)
    cd(destinationString)
    system('qsub submissionFile.sh')
    cd(workingDir)
end