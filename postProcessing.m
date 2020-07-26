clear; close all; clc
% This is the script which is used to export all of the data for the final postprocessing.
% The information we are looking for is:
%
%
% The ASCII files:
% GLSTAT
% MATSUM
% NODFOR
% NODOUT
% RCFORC
%
%
% Furthermore, we would like the geometry:
% Output at each time step:
%   currNodes.txt
% 
% Output once, since it does not change:
%   refElements.txt
%
% Once we have all of this information, we can begin generating plots

% Steps:
%
% 1. Define pointers to the relevant directory
% 2. Create a cfile that can be called to export all of the results.
%       a. This file needs to perhaps be looped over, so we should see if we can
%          figure out the number of steps in the simulation so that we know how 
%          far to loop.
%          Perhaps this can be done by first importing the ASCII files, since they
%          contain the number of states that have been saved.
%
% 3. This will generate quite a lot of data, and we need to figure out a way to keep
%    it organized. The best would probably be to keep the geometry data in a struct 
%    and the ASCII data can perhaps remain in pure matrix form, for the time being.
%
% 4. Obviously, we need some nice visualization at the end, once we have everything.
%    Things to look at are:
%       a. Energy and energy ratios
%       b. Force displacment response
%       c. Stress strain response
%       d. Debonding data
%       e. Geometry changes of the fibers as a function of time
% 
% 5. Since some of the imports take an enormous amount of time, it would be very good
%    to have some save and restore functionality built in from the beginning.
%
%   STATUS:
%   1       OK
%   2       OK
%   3
%   4 
%   5

if ispc
    ctrl.fileSep = '\';
    ctrl.execEnvir = 'Windows';
    nameOfHost = getenv('computername');
else
    ctrl.fileSep = '/';
    ctrl.execEnvir = 'Linux';
    nameOfHost = getenv('HOSTNAME');
end



switch nameOfHost
    case 'AUGUSTBR-DATOR'       % work computer (August)
        lsprepostInstallation = '"C:\Program Files\LSTC\LS-PrePost 4.3\lsprepost4.3_x64.exe"';
    case 'LAPTOP-IPMEKGCS'      % laptop (August)
        lsprepostInstallation = '"C:\Program Files\LSTC\LS-PrePost 4.5\lsprepost4.5_x64.exe"';
    case 'HALLF-SUPER1'         % Windows machine
        lsprepostInstallation = '"C:\Program Files\LSTC\LS-PrePost 4.3\lsprepost4.3_x64.exe"';
    case 'DESKTOP-IVRK4E8'
        lsprepostInstallation = '"C:\Program Files\LSTC\LS-PrePost 4.7\lsprepost4.7_x64.exe"';
    case 'DESKTOP-0052J0Q'
        lsprepostInstallation = 'C:\Program Files\LSTC\LS-PrePost 4.7\lsprepost4.7_x64.exe';
    case 'bertil.hallf.kth.se'
        lsprepostInstallation = '/usr/lsdyna/lsprepost4.7_sles12/lspp47';
    otherwise % 'b-an01.hpc2n.umu.se'
        lsprepostInstallation = '/usr/lsdyna/lsprepost4.7_sles12/lspp47';
end

workingDir = cd;
rmpath(fullfile(workingDir,'auxilliaryFunctionsRestarting'));
addpath(fullfile(workingDir,'auxilliaryFunctionsPostProcessing'));




% Pointer
targetDir = '/scratch/users/august/ExpandaPaper/versionControlled/ShellFiberExpanda/initialCommit_AB_2020-07-23/uncompressed_date_24-Jul-2020'

fileName.exportLSDynaFileAscii = 'cPA.cfile';
fileName.exportLSDynaFileGeometry = 'cPG.cfile';
fileName.exportLSDynaFilePlast = 'cPP.cfile';
fileName.preStampOutputs = 'test6';
fileName.statsNetworkFile = 'statPostprocessing.csv';


if isfile(horzcat(targetDir,ctrl.fileSep,'asciiResults.mat'))
    disp('-----> Loading previously imported ascii results')
    load(horzcat(targetDir,ctrl.fileSep,'asciiResults.mat'))
else
    % Enter database and write results to text files
    createCFilePostProcessing_ascii(fileName,targetDir,ctrl)
    movefile(fileName.exportLSDynaFileAscii,strcat(targetDir,ctrl.fileSep,fileName.exportLSDynaFileAscii))

    extractionFile = horzcat(targetDir,ctrl.fileSep,fileName.exportLSDynaFileAscii);
    system(horzcat(lsprepostInstallation,' c=',extractionFile))

    targetFile = horzcat(targetDir,ctrl.fileSep,fileName.preStampOutputs,'.glstat');
    disp('-----> Importing GLSTAT')
    tic
    outputGLSTAT = collectGlstat(targetFile);
    toc   

    targetFile = horzcat(targetDir,ctrl.fileSep,fileName.preStampOutputs,'.matsum');
    disp('-----> Importing MATSUM')
    tic 
    outputMATSUM = collectMatsum(targetFile);
    toc 

    targetFile = horzcat(targetDir,ctrl.fileSep,fileName.preStampOutputs,'.rcforc');
    disp('-----> Importing RCFORC')
    tic
     outputRCFORC = collectRcforc(targetFile);
    toc

    targetFile = horzcat(targetDir,ctrl.fileSep,fileName.preStampOutputs,'.nodfor');
    try
        disp('-----> Importing NODFOR')
        tic
        outputNODFOR = collectNodfor(targetFile);
        toc
    catch
        disp('-----| No NODFOR file detected. Skipping.')
        disp('-----| Force-displacement info will not be available.')
        outputNODFOR = nan;
    end

    
    
    targetFile = horzcat(targetDir,ctrl.fileSep,fileName.preStampOutputs,'.nodout');
    try
        disp('-----> Importing NODOUT')
        tic
        [outputNODOUT_L,outputNODOUT_R] = collectNodout(targetFile);
        toc
    catch
        disp('-----| No NODOUT file detected. Skipping.')
        disp('-----| Force-displacement info will not be available.')
        outputNODOUT_R = nan;      
        outputNODOUT_L = nan;      
    end

    save(horzcat(targetDir,ctrl.fileSep,'asciiResults.mat'), ...
                                        'outputGLSTAT','outputMATSUM', ...
                                        'outputRCFORC','outputNODFOR', ...
                                        'outputNODOUT_L','outputNODOUT_R');
    disp('     Imported ascii files were saved to the target directory as asciiResults.mat')
end



% Now that we know the size of the output we know how many times to submit the 
% "export currNodes" command when we reopen the simulation database.

loopMax = max(size(outputNODOUT_L,1),size(outputGLSTAT,1));
savePath = createCFilePostProcessing_geometry(fileName,targetDir,loopMax,ctrl);

if isfile(horzcat(targetDir,ctrl.fileSep,'currNodes_',num2str(size(savePath,1)),'.txt'))
    disp('-----> Directory contains nodal coordinates for the final time step.')
    disp('       No new generation of files.')
    
else
    disp('-----> Exporting nodal coordinates for all time steps')
    movefile(fileName.exportLSDynaFileGeometry,strcat(targetDir,ctrl.fileSep,fileName.exportLSDynaFileGeometry))
    extractionFile = horzcat(targetDir,ctrl.fileSep,fileName.exportLSDynaFileGeometry);
    system(horzcat(lsprepostInstallation,' c=',extractionFile))
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we now need to loop through all of the files and back-calculate the
% deformed geometry. This will take quite some time of course. We should
% save the result for each time step as it comes in.

if isfile(horzcat(targetDir,ctrl.fileSep,'elementConnectivity.mat'))
    load(horzcat(targetDir,ctrl.fileSep,'elementConnectivity.mat'))
    disp('-----> Loading previously imported element data')
else
    elementFile = horzcat(targetDir,ctrl.fileSep,'refElements.txt');
    disp('----> Importing elements')
    elements = importElements(elementFile);
    elements(isnan(elements(:,1)),:) = [];
    save(horzcat(targetDir,ctrl.fileSep,'elementConnectivity.mat'),'elements');
end


if isfile(horzcat(targetDir,ctrl.fileSep,'nodalCollectionComplete.mat'))
    load(horzcat(targetDir,ctrl.fileSep,'nodalCollectionComplete.mat'))
    disp('-----> Loading previously imported nodal data')
else
    disp('----> Importing nodes')
%     if isfile(horzcat(targetDir,ctrl.fileSep,'nodalCollection.mat'))
%         load(horzcat(targetDir,ctrl.fileSep,'nodalCollection.mat'))
%         startIdx = numel(nodesCollect)+1;
%     else
%         startIdx = 1;
%     end
            
    for cLoop = 1:size(savePath,1)%startIdx:size(savePath,1)
        tic
        nodeFile = horzcat(targetDir,ctrl.fileSep,'currNodes_',num2str(cLoop),'.txt');
        
        disp(['      Load step: ' num2str(cLoop) ' / ' num2str(size(savePath,1))])
%         nodesCollect(cLoop).nodes = importNodes(nodeFile);
        nodesCollect(cLoop).nodes  = importNodesFast(nodeFile);
        nodesCollect(cLoop).nodes(isnan(nodesCollect(cLoop).nodes(:,1)),:) = [];
%         save(horzcat(targetDir,ctrl.fileSep,'nodalCollection.mat'),'nodesCollect','-v7.3');
        toc
    end    
    save(horzcat(targetDir,ctrl.fileSep,'nodalCollectionComplete.mat'),'nodesCollect','-v7.3');
end

% Options:
% ctrl.saveOutputOnExit = 1; % Save a ,.mat file with the results so that further steps can be performed
%                            % without re-running.
%                            % 0 = No, 1 = Yes.
ctrl.plotMode = 0;         % Plot diagnostic plots or not. Will slow down the code but allows continuous supervision.
                           % 0 = No plotting inside for-loops. 1 = Plotting fiber by fiber.
ctrl.verbose = 0;          % Controls the number of comments written out during the solution
                           % 0 = Only necessary information. 1 = Debug-level reporting.
ctrl.aDiv = 16;

if isfile(horzcat(targetDir,ctrl.fileSep,'geoResultsComplete.mat'))      
    disp('-----> Loading previously calculated geoResults')
    load(horzcat(targetDir,ctrl.fileSep,'geoResultsComplete.mat'))
else
    figure
    for bLoop = 1:size(savePath,1)

        tic
%        geoResults(bLoop).condensedData = postProcessingGeometry(nodesCollect(bLoop).nodes,elements,ctrl);
%        geoResults(bLoop).condensedData = postProcessingGeometry_v2(nodesCollect(bLoop).nodes,elements,ctrl);
%        [geoResults(bLoop+1).condensedData,restoreGeom] = postProcessingGeometry_v2(nodesCollect(bLoop).nodes,elements,ctrl);
%        [geoResults(bLoop+1).condensedData,restoreGeom2] = postProcessingGeometry_v2(nodesCollect(bLoop).nodes,elements,ctrl,restoreGeom);
        

        % Check if there is a restoreGeom in the directory above. This
        % minimizes the risk of reconstruction errors, which is quite nice.
        % Should also save some time.
        if exist('restoreGeom')
            disp('       Using restored geometry.')
            [geoResults(bLoop).condensedData,~] = postProcessingGeometry_v2(nodesCollect(bLoop).nodes,elements,ctrl,ctrl.aDiv,restoreGeom);
        elseif isfile(horzcat(targetDir,ctrl.fileSep,'restoreGeom.mat')) 
            disp('       Using restored geometry.')
            load(horzcat(targetDir,ctrl.fileSep,'restoreGeom.mat'))
            [geoResults(bLoop).condensedData,~] = postProcessingGeometry_v2(nodesCollect(bLoop).nodes,elements,ctrl,ctrl.aDiv,restoreGeom);
        else
            try 
                [~,mTemp] = strtok(flip(targetDir(2:end)),ctrl.fileSep);
                motherDir = horzcat(ctrl.fileSep,flip(mTemp));
                load(horzcat(motherDir,ctrl.fileSep,'restoreGeom.mat'))
                save(horzcat(targetDir,ctrl.fileSep,'restoreGeom.mat'),'restoreGeom','-v7.3')
                disp('      Successfully loaded restoreGeom from top directory.')
                [geoResults(bLoop).condensedData,~] = postProcessingGeometry_v2(nodesCollect(bLoop).nodes,elements,ctrl,ctrl.aDiv,restoreGeom);
            catch
                disp('       There is no restored geometry in the top directory.')
                disp('       Consider aborting and running the reconstruction there first to maximize quality of reconstruction.')
                disp('')
        
%         else
                disp('        No restored geometry detected. Generating (slow).')
                [geoResults(bLoop).condensedData,restoreGeom] = postProcessingGeometry_v2(nodesCollect(bLoop).nodes,elements,ctrl,ctrl.aDiv);
                save(horzcat(targetDir,ctrl.fileSep,'restoreGeom.mat'),'restoreGeom','-v7.3')
                disp('-----> Saving restoreGeom to disk')
            end
        end
        toc
%         tic
% %         save(horzcat(targetDir,ctrl.fileSep,'geoResultsTemp.mat'),'geoResults','-v7.3')
%         toc
%         
%     subplot(2,2,1)
%     plot([bLoop],[mean([geoResults(bLoop).condensedData.Lc],'omitnan')],'ob')
%     hold on
%     xlabel('Time step'); ylabel('Lc [um]')
%     
%     subplot(2,2,2)
%     plot([bLoop],[mean([geoResults(bLoop).condensedData.Lp],'omitnan')],'ob')
%     hold on
%     xlabel('Time step'); ylabel('Lp [um]')
%     
%     subplot(2,2,3)
%     plot([bLoop],[mean([geoResults(bLoop).condensedData.widthMean],'omitnan')],'ob')
%     hold on
%     xlabel('Time step'); ylabel('Mean Width [um]')
%     
%     subplot(2,2,4)
%     plot([bLoop],[mean([geoResults(bLoop).condensedData.heightMean],'omitnan')],'ob')
%     hold on
%     xlabel('Time step'); ylabel('Mean Height [um]')
%     pause(0.2)
    end
    disp('-----> Saving results')
    save(horzcat(targetDir,ctrl.fileSep,'geoResultsComplete.mat'),'geoResults','-v7.3')

end



% Visualization section of the script
figure;

for dLoop = 1:numel(geoResults) % Why not 1??????
    subplot(2,2,1)
    plot([dLoop],[mean([geoResults(dLoop).condensedData.Lc],'omitnan')],'ob')
    hold on
    xlabel('Time step'); ylabel('Lc [um]')
    
    subplot(2,2,2)
    plot([dLoop],[mean([geoResults(dLoop).condensedData.Lp],'omitnan')],'ob')
    hold on
    xlabel('Time step'); ylabel('Lp [um]')
    
    subplot(2,2,3)
    plot([dLoop],[mean([geoResults(dLoop).condensedData.widthMean],'omitnan')],'ob')
    hold on
    plot([dLoop],[std([geoResults(dLoop).condensedData.widthStd],'omitnan')],'rs')
    xlabel('Time step'); ylabel('Mean Width [um]')
    
    subplot(2,2,4)
    plot([dLoop],[mean([geoResults(dLoop).condensedData.heightMean],'omitnan')],'ob')
    hold on
    plot([dLoop],[std([geoResults(dLoop).condensedData.heightStd],'omitnan')],'rs')
%     plot([dLoop],[mean([geoResults(dLoop).condensedData.heightMean],'omitnan')]-[std([geoResults(dLoop).condensedData.heightStd],'omitnan')],'rs')
    xlabel('Time step'); ylabel('Mean Height [um]')

end

cd(workingDir)
fileID = fopen(fileName.statsNetworkFile,'w');
fprintf(fileID,'%s\n','Network postprocessing summary');
fprintf(fileID,'%s\n','');
fprintf(fileID,'%s\n','Environment information');
fprintf(fileID,'%s\n','');

fprintf(fileID,'File generated                %s\n',datestr(now));
fprintf(fileID,'Computer architecture         %s\n',computer('arch'));
fprintf(fileID,'MATLAB version                %s\n',version);
fprintf(fileID,'Computer name was reported as %s\n',nameOfHost);

fclose(fileID);


if ispc


% figure;
% f4.draw();
% f4.export('file_name','heightVsTime','export_path','outToChiara_18112019\','file_type','png','width',14,'height',10);
% f4.export('file_name','heightVsTime','export_path','outToChiara_18112019\','file_type','eps','width',14,'height',10);
% Temp enhance GEOMTEMP to include directional data
% Step 1: End-to-end orientation
% Step 2: Midline section orientation
figure
for eLoop = 1:numel(geoResults)
    
    for fLoop = 1:numel(geoResults(eLoop).condensedData)
        
        sTemp = find(not(isnan(geoResults(eLoop).condensedData(fLoop).midLine(:,1))),1);
        eTemp = find(not(isnan(geoResults(eLoop).condensedData(fLoop).midLine(:,1))),1,'last');
        
        if sTemp ~= eTemp & size(eTemp,1)>0 & size(sTemp,1) > 0
        
        startTemp = geoResults(eLoop).condensedData(fLoop).midLine(sTemp,:);
        endTemp = geoResults(eLoop).condensedData(fLoop).midLine(eTemp,:);
    
        fibOrientTemp = diff([endTemp ; startTemp],1,1);
        fibOrientTemp = fibOrientTemp./norm(fibOrientTemp);
        fibOrientTempDeg = rad2deg(acos(dot(fibOrientTemp,[0 0 1])));
    
        geoResults(eLoop).condensedData(fLoop).fibOrientation = mod(fibOrientTempDeg,180);
        else
            geoResults(eLoop).condensedData(fLoop).fibOrientation = nan;
        end
    
    end
    
%     subplot(1,2,1)
%     histogram([geoResults(eLoop).condensedData.fibOrientation],'DisplayStyle','stairs','Normalization','cdf')
%     hold on
%     pause(5)
    
    atemp = [geoResults(1).condensedData.fibOrientation];
    selT1 = atemp < 45 | atemp > 135;
    selT2 = atemp > 45 & atemp < 135;

    subplot(1,3,1)
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT1).Lp],'omitnan')],'ob')
    hold on
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT2).Lp],'omitnan')],'sr')
    xlabel('time step'); ylabel('Projected fiber length [\mu m]'); title('Split at 45 deg')
    % pause(5)
   
    selT1 = atemp < 60 | atemp > 120;
    selT2 = atemp > 60 & atemp < 120;

    subplot(1,3,2)
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT1).Lp],'omitnan')],'ob')
    hold on
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT2).Lp],'omitnan')],'sr')
    xlabel('time step'); ylabel('Projected fiber length [\mu m]'); title('Split at 60 deg from MD')
    
    selT1 = atemp < 15 | atemp > 165;
    selT2 = (atemp > 15 & atemp < 30) | (atemp < 165 & atemp > 150);
    selT3 = (atemp > 30 & atemp < 45) | (atemp < 150 & atemp > 135);
    selT4 = (atemp > 45 & atemp < 60) | (atemp < 135 & atemp > 120);
    selT5 = (atemp > 60 & atemp < 75) | (atemp < 120 & atemp > 105);
%     selT1 = (atemp > 75 & atemp < 75) | (atemp < 120 & atemp > 105);
    selT6 = atemp > 75 & atemp < 105;

    tempCols = winter(6);
    subplot(1,3,3)
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT1).Lp],'omitnan')],'o','color',tempCols(1,:))
    hold on
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT2).Lp],'omitnan')],'o','color',tempCols(2,:))
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT3).Lp],'omitnan')],'o','color',tempCols(3,:))
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT4).Lp],'omitnan')],'o','color',tempCols(4,:))
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT5).Lp],'omitnan')],'o','color',tempCols(5,:))
    plot([eLoop],[mean([geoResults(eLoop).condensedData(selT6).Lp],'omitnan')],'o','color',tempCols(6,:))
    xlabel('time step'); ylabel('Projected fiber length [\mu m]'); title('Binned at 15 deg')
   
   
   
end


% Another fun plot: variance of width as a function of time






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Histogram of first and last step



nPoints = 1e3;


figure();
f1(1,1) = gramm('x',{[geoResults(1).condensedData(:).Lc],[geoResults(end).condensedData(:).Lc]},'color',{'1','22'})
% f1(1,1).stat_density('npoints',nPoints);
f1(1,1).stat_bin('geom','stairs','normalization','probability');
f1(1,1).set_names('x','Fiber Length [$\mu$m]', ...
                  'y','Relative Probability $v_i = c_i/N \leq 1$', ...
                  'color','Time step');
f1(1,1).axe_property('xlim',[0 inf],'ylim',[0 inf])
f1(1,1).set_text_options('font','Times New Roman', ...
                    'interpreter','latex', ...
                    'base_size',14);
% f1(1,1).set_layout_options('legend_position',[0.5 0.5 0.5 0.5]);        
% f1(1,1).set_layout_options('legend',0,'margin_width',[0.2 0.2],'margin_height',[0.2 0.2],'redraw',false);
f1.draw();
mkdir('outToChiara_18112019')
f1.export('file_name','lengthHistogram','export_path','outToChiara_18112019\','file_type','png','width',14,'height',10);
f1.export('file_name','lengthHistogram','export_path','outToChiara_18112019\','file_type','eps','width',14,'height',10);

figure();
f2 = gramm('x',{[geoResults(1).condensedData(:).widthMean],[geoResults(end).condensedData(:).widthMean]},'color',{'1','22'})
% f1(1,1).stat_density('npoints',nPoints);
f2.stat_bin('geom','stairs','normalization','probability');
f2.set_names('x','Fiber Width [$\mu$m]', ...
                  'y','Relative Probability $v_i = c_i/N \leq 1$', ...
                  'color','Time step');
f2.axe_property('xlim',[0 inf],'ylim',[0 inf]);
f2.set_text_options('font','Times New Roman', ...
                    'interpreter','latex', ...
                    'base_size',14);
% f1(1,1).set_layout_options('legend_position',[0.5 0.5 0.5 0.5]);        
% f1(1,1).set_layout_options('legend',0,'margin_width',[0.2 0.2],'margin_height',[0.2 0.2],'redraw',false);
f2.draw();
f2.export('file_name','widthHistogram','export_path','outToChiara_18112019\','file_type','png','width',14,'height',10);
f2.export('file_name','widthHistogram','export_path','outToChiara_18112019\','file_type','eps','width',14,'height',10);


figure();
f3 = gramm('x',{[geoResults(1).condensedData(:).heightMean],[geoResults(end).condensedData(:).heightMean]},'color',{'1','22'})
% f1(1,1).stat_density('npoints',nPoints);
f3.stat_bin('geom','stairs','normalization','probability');
f3.set_names('x','Fiber Width [$\mu$m]', ...
                  'y','Relative Probability $v_i = c_i/N \leq 1$', ...
                  'color','Time step');
f3.axe_property('xlim',[0 inf],'ylim',[0 inf])
f3.set_text_options('font','Times New Roman', ...
                    'interpreter','latex', ...
                    'base_size',14);
% f1(1,1).set_layout_options('legend_position',[0.5 0.5 0.5 0.5]);        
% f1(1,1).set_layout_options('legend',0,'margin_width',[0.2 0.2],'margin_height',[0.2 0.2],'redraw',false);
f3.draw();
f3.export('file_name','heightHistogram','export_path','outToChiara_18112019\','file_type','png','width',14,'height',10);
f3.export('file_name','heightHistogram','export_path','outToChiara_18112019\','file_type','eps','width',14,'height',10);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Binning on fiber orientation
% for dLoop = 1:numel(geoResults)
%    LcVec(dLoop) =  mean([geoResults(dLoop).condensedData.Lc(mod([geoResults(dLoop).condensedData.fibOrientation],90)<45)],'omitnan');
%    LcVec2(dLoop) =  mean([geoResults(dLoop).condensedData.Lc(mod([geoResults(dLoop).condensedData.fibOrientation],90)>45)],'omitnan');
% end
% 
% xVec = [1:numel(geoResults)]./numel(geoResults);
% 
% f1 = gramm('x',xVec,'y',LcVec);
% f1.geom_point();
% f1.geom_line();
% f1.set_names('x','Pseudo-time [-]', ...
%              'y','Mean Length [$\mu$m]');
% % f1.axe_property('xlim',[0 200],'ylim',[-45 -0]);
% f1.set_text_options('font','Times New Roman', ...
%                     'interpreter','latex', ...
%                     'base_size',14);
% f1.set_point_options('base_size',8);
% figure;
% f1.draw();
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plasticity import

if isfile(horzcat(targetDir,ctrl.fileSep,'epsCollectionComplete.mat'))
    disp('-----> Loading previously imported plasticity results')
    load(horzcat(targetDir,ctrl.fileSep,'elementVolume.mat'))
    load(horzcat(targetDir,ctrl.fileSep,'epsCollectionComplete.mat'))
else
    disp('-----> Exporting volume and effective plastic strain data')
    % Enter database and write results to text files
    savePath = createCFilePostProcessing_plast(fileName,targetDir,loopMax,ctrl);
    movefile(fileName.exportLSDynaFilePlast,strcat(targetDir,ctrl.fileSep,fileName.exportLSDynaFilePlast))

    extractionFile = horzcat(targetDir,ctrl.fileSep,fileName.exportLSDynaFilePlast);
    system(horzcat(lsprepostInstallation,' c=',extractionFile))
    
    disp('-----> Importing volume data')
    elementVolume = importfileVolume(horzcat(targetDir,ctrl.fileSep,'eVolumes.txt'));
    elementVolume(isnan(elementVolume(:,1)),:) = [];
    save(horzcat(targetDir,ctrl.fileSep,'elementVolume.mat'),'elementVolume','-v7.3')
    disp('-----> Importing plasticity data for all elements')
    for cLoop = 1:size(savePath,1)
    
        epsFile = horzcat(targetDir,ctrl.fileSep,'currEps_',num2str(cLoop),'.txt');
        
        disp(['      Load step: ' num2str(cLoop) ' / ' num2str(size(savePath,1))])
        fileID = fopen(epsFile);
        filemod = textscan(fileID,'%s','delimiter','\n','whitespace', '');
        fclose(fileID);
        filemod = filemod{1,1};
        % Find all the keywords and their positions
        startIndex = regexp(filemod,'*');
        tf = cellfun('isempty',startIndex);         % true for empty cells
        startIndex(tf) = {0};                       % replace by a cell with a zero 
        startIndex = cell2mat(startIndex);
        [pk,~] = find(startIndex);



        filemod(pk(5):end) = []; % Delete everything except the part about initial stresses.
        filemod(1:pk(4)-1) = [];

        filemod(1:2) = [];

        eCollect = nan(size(elementVolume,1),4);
%         figure;
        selIdx = 1;
        for zLoop = 1:4:numel(filemod) % Skipping first two rows with legend data

            tline = filemod{zLoop};
            tlength = length(tline);

            eCollect(selIdx,1) = str2double(tline(1:10));

            loopSize = str2double(tline(21:30));
            for xLoop = 1:loopSize
                tline = filemod{zLoop + xLoop};
                eCollect(selIdx,1+xLoop) = str2double(tline(71:80));
            end
            selIdx = selIdx + 1;
        end
        epsCollect(cLoop).eps = eCollect;
    
%         save(horzcat(targetDir,ctrl.fileSep,'epsCollection.mat'),'epsCollect','-v7.3');
    end    
    save(horzcat(targetDir,ctrl.fileSep,'epsCollectionComplete.mat'),'epsCollect','-v7.3');     
end       

