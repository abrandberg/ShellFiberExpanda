%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Network Generator
% Part of the ShellFiberExpanda toolbox
%
%
% ABOUT:
% This script contains the inputs to deposit fibers which when compressed will 
% form a network similar to a paper sheet or paperboard. Please refer to the 
% README file for general information about the repository, it's overall
% philosophy and intended usage.
%
% INPUTS:
% All inputs are specified in this script. However, the script assumes some files
% have been created ahead of time. In general those files should be located in the
% folder
%   explicitInstructions
%                           where "explicit" refers to the fact that LS-Dyna can be
% run using both implicit and explicit solvers (here using the explicit one) and 
% "Instructions" refers to the fact that these KEYWORD commands should in general be
% static: the script simply reads them in and appends them to the rest of the inputs.                    
%
%
% 
%
%
% Created by: August Brandberg augustbr at kth . se
% date: 2020-07-23

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meta instructions
clear; close all; clc
format compact
workingDir = cd;
[~, nameOfHost] = system('hostname');
nameOfHost = cellstr(nameOfHost);
addpath(fullfile(workingDir,'auxilliaryFunctionsGeneration'));
addpath(fullfile(workingDir,'explicitInstructions'));

rng(0);         
% Seed used in the published network generation. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
% The structure ctrl contains most of the information which is needed to control
% the behavior of matlab during the running of the simulation.
% ctrl.filesep              - File separator, \ or / depending on environment
%     .execEnvir            - String with environment name for future use
%     .plotFlag             - More or less plotting. Convenient if you do not 
%                             have an X11 instance active
%     .plotDirectory        - Directory where plots will be saved
%     .executeDirectly      - Boolean deciding whether the script will try to 
%                             submit the job. As a general rule doesn't work.
if ispc
    ctrl.fileSep = '\';
    ctrl.execEnvir = 'Windows';
else
    ctrl.fileSep = '/';
    ctrl.execEnvir = 'Linux';
end
ctrl.plotFlag = 0;
ctrl.plotDirectory = 'Plots';
ctrl.executeDirectly = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File name pointers
% The following pointers to files and directories need to be defined:
%  fileName.batchDir         - Directory where everything will be moved. 
%                              Created at runtime, overwrites previous content.
%          .mainCard         - File which will be called by the job scheduler
%          .databaseCard     - File with output controls
%          .exeFile          - File which communicates with the job scheduler
%          .outputFile       - File with the information communicated by the solver during
%                              the run
%          .statsFiberFile   - Contains the fiber geometry of each fiber created.
%          .statsNetworkFile - Output aggregate statistics of the network.   
fileName.batchDir         = 'initialCommit_AB_2020-07-23';
fileName.mainCard         = 'Main_card_v8.k';
fileName.databaseCard     = 'Database_output_for_explicit.k';
fileName.exeFile          = 'submissionFile.sh';
fileName.outputFile       = 'outputScreen.txt';
fileName.statsFiberFile   = 'statisticsFibers.csv';
fileName.statsNetworkFile = 'statisticsNetwork.csv';
fileName.fStatsFile       = 'fStats.mat';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Physical characterization controls
% Controls the domain in which fibers will be created and some solution/target values.
%  physicsControl.xDim               - [um]{1x2} vector with the min and max x-coordinate of the network
%                .zDim               - [um]{1x2} vector with the min and max z-coordinate of the network
%                .targetThickness    - [um] Thickness to which to press the stack
%                .targetGrammage     - [g/m^2] Target grammage for the depositor functions
%                                      which use that functionality. Should be used by new
%                                      users.
%                .minFiberLength     - [um] Lower bound for fiber length. If shorter, fiber is
%                                      considered a fine and dropped. Grammage contribution
%                                      is also dropped.
%                .networkMarginPadding [um] Amount of extra space that where fibers can be
%                                      deposited. Should be no less than 2000 um unless you
%                                      have a good reason. Good reasons include unusually
%                                      short fibers and unusually small solution domain.
%                .fiberDensity       - [kg/m^3] Fiber density. Should be set to about 1500
%                                      kg/m^3 unless there is a good reason. Good reasons
%                                      include that you are modelling a swollen state due
%                                      to water uptake.
%                .lambda             - [-] Anisotropy ratio according to Forgacs & Strelis, 1963
physicsControl.xDim = [0 6000];
physicsControl.zDim = [0 6000];
physicsControl.targetThickness = 200;
physicsControl.targetGrammage = 10;
physicsControl.minFiberLength = 100;
physicsControl.networkMarginPadding = 2000;
physicsControl.fiberDensity = 1500;
physicsControl.lambda = 1;

if physicsControl.networkMarginPadding < 1000
    disp('You have set networkMarginPadding to < 1000.')
    disp('It is unlikely this will work.')
    disp(stop)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerical furnish controls 
% Controls the pulp used, mainly by filtering
%  furnishControl.removeNans            - [Bool] Controls whether NANs and incomplete rows are deleted.
%                .curlBoundLower        - [%] Minimum accepted fiber curl
%                .curlBoundUpper        - [%] Maximum accepted fiber curl
%                .wallTknBoundLower     - [um] Minimum accepted wall thickness
%                .wallTknBoundUpper     - [um] Maximum accepted wall thickness
%                .diameterBoundLower    - [um] Minimum accepted fiber diameter 
%                .diameterBoundUpper    - [um] Maximum accepted fiber diameter
%                .swellingFactorDiameter  [-] Swelling factor for diameter
%                .swellingFactorWallTkn   [-] Swelling factor for the wall
%
% The swelling factors work by multiplication, e.g. a swellingFactorDiameter =0.2 means
% an observed fiber diameter of 100 um (observed in the wet state) will be generated as
% a 0.2*100 = 20 um fiber diameter in the FEM model.
%
furnishControl.removeNans = 1;
furnishControl.curlBoundLower = 0;
furnishControl.curlBoundUpper = 20;
furnishControl.wallTknBoundLower = 1;
furnishControl.wallTknBoundUpper = 15;
furnishControl.diameterBoundLower = 5;
furnishControl.diameterBoundUpper = 50;
furnishControl.swellingFactorDiameter = 0.7399;
furnishControl.swellingFactorWallTkn = 0.3645;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mesh controls
% Handles everything about mesh, such as element type and h-density.
%  meshControl.aDiv                     - Number of elements around the circumference of a
%                                         fiber cross-section
%             .aspectRatio              - Factor between the longer and the shorter
%                                         in-plane element length
%             .plateElementSize         - [um] Target element size in plates
%             .plateElementHeight       - [um] Solid element thickness
%             .shellType                - Shell element formulation. Use 16.
meshControl.aDiv = 16;
meshControl.aspectRatio = 1;
meshControl.plateElementSize = 20;
meshControl.plateElementHeight = 20;
meshControl.shellType = 16;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execution information
% Structure with the information pertaining to the running of the
% simulation. For example, clusters typically want jobs to be submitted
% using job handlers: The information necessary to submit to the them is
% found here.
%
% CAVEAT: THIS IS HIGHLY SPECIFIC TO MY EMPLOYER, KTH ENGINEERING MECHANICS.
%         PLEASE GENERATE A FILE TO SEE THE STRUCTURE, THEN ADJUST TO FIT
%         YOUR NEEDS!
%
% The exeInformation structure contains the following fields:
%   exeInformation.exeFileName      - Name of the (typically .sh) file to be created
%                 .np               - Number of processors to request
%                 .mainCardFile     - The main file name, which then imports the rest of the instructions
%                 .outputFile       - File name into which to write output
%                 .exeEnvironment   - Cluster where simulation will be submitted. Currently supports:
%                                     'bertil'     - bertil.hallf.kth.se
%                                     'burster'    - burster.hallf.kth.se
%                                     'tensor'     - tensor.hallf.kth.se
%                                     'kebnekaise' - kebnekaise.hpc2n.umu.se
%                 .exeTime          - Max time before simulation is terminated. Only for kebnekaise.
%                                     Format:
%                                     '5-23:00:00' (5 days, 23 hours, 0 minutes, 0 seconds)
exeInformation.exeFileName    = fileName.exeFile;
exeInformation.np             = 24;              
exeInformation.mainCardFile   = fileName.mainCard;
exeInformation.outputFile     = fileName.outputFile;
exeInformation.exeEnvironment = 'bertil';
exeInformation.exeTime        = '0-23:00:00';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Contact detection algoritm: Projection, bounding box
% This is the call to generate the initial "stack" of fibers.
fiberMode ='billerud'; % Do not change.
[fStats,yDim,fileName] = fiberDepositor_v12(physicsControl, ...
                                                            fiberMode,0,    ...
                                                            meshControl,    ...
                                                            fileName,       ...
                                                            furnishControl,ctrl);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save the fStats file which contains the information regarding each fiber
formatSpec = '%14d %14.4f %14.4f %14.4f %14.4f %14.4f %14.4e %14.4e %14.4f %14.4f \n';
fileID = fopen(fileName.statsFiberFile,'w');
fprintf(fileID,formatSpec,fStats'); 
fclose(fileID);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save misc. data about the environment, the network
rngInfo = rng;
fileID = fopen(fileName.statsNetworkFile,'w');
fprintf(fileID,'%s\n','Network generation summary');
fprintf(fileID,'%s\n','');
fprintf(fileID,'%s\n','Environment information');
fprintf(fileID,'Pseudo-unique identifier      %s\n',fileName.networkSaveName(1:end-4));
fprintf(fileID,'File generated                %s\n',datestr(now));
fprintf(fileID,'Computer architecture         %s\n',computer('arch'));
fprintf(fileID,'MATLAB version                %s\n',version);
fprintf(fileID,'Computer name was reported as %s\n',nameOfHost{1,1});
fprintf(fileID,'MATLAB reported rng-seed      %d\n',rngInfo.Seed);

fprintf(fileID,'%s\n','');
fprintf(fileID,'%s\n','Domain information');
fprintf(fileID,'Length along global x       = %10.2f um \n',diff(physicsControl.xDim));
fprintf(fileID,'Length along global z       = %10.2f um \n',diff(physicsControl.zDim));
fprintf(fileID,'Height to compress (y)      = %10.2f um \n',yDim);
fprintf(fileID,'Computational domain volume = %10.3e um^3 \n',diff(physicsControl.xDim)*yDim*diff(physicsControl.zDim));
fprintf(fileID,'Mass in domain              = %10.3e kg \n',sum(fStats(:,8)));
fprintf(fileID,'Grammage of sample          = %10.2f g/m^2 \n',sum(fStats(:,8))*1e3/(1e-12*diff(physicsControl.xDim*diff(physicsControl.zDim))));
fprintf(fileID,'Number of fibers in domain  = %10.0f \n',size(fStats,1));

fprintf(fileID,'%s\n','');
fprintf(fileID,'%s\n','Furnish information');
fprintf(fileID,'Mean fiber length (truncated+projected) = %10.2f um \n',mean(fStats(:,2)));
fprintf(fileID,'Mean fiber length (truncated)           = %10.2f um \n',mean(fStats(:,3)));
fprintf(fileID,'Mean fiber radius                       = %10.2f um \n',mean(fStats(:,4)));
fprintf(fileID,'Mean fiber wall thickness               = %10.2f um \n',mean(fStats(:,5)));
fprintf(fileID,'Mean fiber orientation                  = %10.2f degrees \n',mean(fStats(:,9)));
fprintf(fileID,'%s\n','');

fclose(fileID);

disp('Saving fStats')
save(fileName.fStatsFile,'fStats','-v7.3')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mesh section
% Here the nodal, element data is generated.
nameString = strcat('uncompressed_date_',datestr(date));
mkdir([fileName.batchDir ctrl.fileSep nameString])

% Move the resulting file into its own directory
destinationString = strcat(workingDir,ctrl.fileSep,fileName.batchDir,ctrl.fileSep,nameString);

physicsControl.solTime = 8*yDim/100*1e-6;
LSDynaOutputInterval('Database_output_for_explicit_variable.k',fileName.databaseCard,physicsControl.solTime);


copyfile(horzcat('explicitInstructions',ctrl.fileSep,fileName.mainCard),strcat(destinationString,ctrl.fileSep,fileName.mainCard))
movefile('centerLines.csv',        strcat(destinationString,ctrl.fileSep,'centerLines.csv'))
movefile(fileName.databaseCard,    strcat(destinationString,ctrl.fileSep,fileName.databaseCard))
movefile(fileName.statsFiberFile,  strcat(destinationString,ctrl.fileSep,fileName.statsFiberFile))
movefile(fileName.statsNetworkFile,strcat(destinationString,ctrl.fileSep,fileName.statsNetworkFile))
movefile(fileName.networkSaveName, strcat(destinationString,ctrl.fileSep,fileName.networkSaveName))
movefile(fileName.fStatsFile, strcat(destinationString,ctrl.fileSep,fileName.fStatsFile))

cd(destinationString)
createSubmissionScript(exeInformation);
disp('-> ENTERING MESHING MODULE')
matlabMeshing_v3(meshControl,physicsControl,0);
if ctrl.executeDirectly
    system('qsub submissionFile.sh')
end
cd(workingDir)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save generated figures
exportFigures(ctrl);

% This is the end of the script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%