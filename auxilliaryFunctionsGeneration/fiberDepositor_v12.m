function [fStats,yDim,fileName] = fiberDepositor_v12(physicsControl,fiberMode,modeFlag,meshControl,fileName,furnishControl,ctrl)
%function fiberDepositor_v12(physicsControl,fiberMode,modeFlag,meshControl,fileName,furnishControl,ctrl)
%samples fibers and deposits them on the rectangular surface spanned by [xDim X zDim]. If a fiber crosses the 
%boundary of the surface, it is cut.
%
%The function also creates two files, one containing the midpoints of the 
%deposited fiber and one containing the directional angles from one midpoint
%to the next. 
%
%INPUTS:        In general the inputs come from the file networkGeneration.m
%               Please refer to the documentation there.
%
%
%OUTPUTS:       fStats      - Collection of statistics for plotting.
%                             Contents:
%                               (1) Fiber index (depoFibers)
%                               (2) Fiber length - projected (lFiberProj)
%                               (3) Fiber length - real (lFiber)
%                               (4) Fiber midwall radius (rFiber)
%                               (5) Fiber wall thickness (tFiber)
%                               (6) Fiber curvature (cFiber)
%                               (7) Fiber volume (lFiber*rFiber*2*pi*tFiber)
%                               (8) Fiber mass (assumption density 1500 kg/m^3)
%                               (9) Angle relative to Z axis in degrees
%                              (10) Fiber location on Y axis
%               yDim        - [um] Height of the stack created.
%               fileName    - A string pointing to a save of the output.
%REMARKS:
%
%
%
%created by: August Brandberg augustbr at kth . se
%date: 27-10-2018
%

xDim = physicsControl.xDim;
zDim = physicsControl.zDim;

fStats = zeros(1,10);
if modeFlag == 1
    A=figure(); 
    B=figure(); 
    C=figure();
    D=figure();
    E=figure();
end
tTemp = zeros(1,1);


% Create a structure to be compared with each new fiber for intersections.
existingFibers = [];
exportStructure = 1:7;

depoFibers = 0;
possibleX = [xDim(1)-physicsControl.networkMarginPadding xDim(2)+physicsControl.networkMarginPadding];
possibleZ = [zDim(1)-physicsControl.networkMarginPadding zDim(2)+physicsControl.networkMarginPadding];
currentGrammage = 0;

% If custom sampling, prepare the sampling array. 
if strcmp(fiberMode,'billerud')
    [numericalFurnishArray] = csvTypeFurnish(fiberMode,furnishControl,ctrl);
else
    numericalFurnishArray = [];
end
disp('-> ENTERING FIBER DEPOSITION MODULE')

while currentGrammage < physicsControl.targetGrammage
    tic
    fiberOutside = 1;
    while fiberOutside       
        [startPos,lFiberProj,rFiber,tFiber,cFiber] = fiberCreator(possibleX,possibleZ,fiberMode,numericalFurnishArray);

        angXZ = orientFiber(physicsControl,ctrl);
        startPos = [startPos(1) 0 startPos(2)]; 
        endPos = startPos + lFiberProj.*[cosd(angXZ) 0 sind(angXZ)];
        
        if modeFlag == 1
           figure(E) 
           hold off
           plot([possibleX(1) possibleX(2) possibleX(2) possibleX(1) possibleX(1)],[possibleZ(1) possibleZ(1) possibleZ(2) possibleZ(2) possibleZ(1)],'k-.','linewidth',2)
           hold on
           plot([xDim(1) xDim(2) xDim(2) xDim(1) xDim(1)],[zDim(1) zDim(1) zDim(2) zDim(2) zDim(1)],'color', 'r','linewidth',2)
           hold on
           plot([startPos(1) endPos(1)],[startPos(3) endPos(3)],'color','b')
           %hold on
           axis equal
           xlabel('x'); ylabel('y'); zlabel('z');
           print(gcf,'fiber0','-dpng','-r600')
        end
        
        % This is the updated part: we need to check if both the start and the
        % endpoint is inside the bounding box. If only one of them is, we need
        % to "flip" the start and the end position.  
        startPosInside = startPos(1) > xDim(1) && startPos(3) > zDim(1) && startPos(1) < xDim(2) && startPos(3) < zDim(2);
        endPosInside   =   endPos(1) > xDim(1) &&   endPos(3) > zDim(1) &&   endPos(1) < xDim(2) &&   endPos(3) < zDim(2);

        if startPosInside && endPosInside
            fiberOutside = 0;
        elseif startPosInside
            fiberOutside = 0;
            if endPos(1) < xDim(1) 
                endPos(3) = startPos(3)+(endPos(3)-startPos(3))/(endPos(1)-startPos(1))*(xDim(1)-startPos(1));
                endPos(1) = xDim(1);
            end
            if endPos(3) < zDim(1)
                endPos(1) = startPos(1)+(endPos(1)-startPos(1))/(endPos(3)-startPos(3))*(zDim(1)-startPos(3));
                endPos(3) = zDim(1); 
            end
            if endPos(1) > xDim(2)
                endPos(3) = startPos(3)+(endPos(3)-startPos(3))/(endPos(1)-startPos(1))*(xDim(2)-startPos(1));
                endPos(1) = xDim(2); 
            end
            if endPos(3) > zDim(2)
                endPos(1) = startPos(1)+(endPos(1)-startPos(1))/(endPos(3)-startPos(3))*(zDim(2)-startPos(3));
                endPos(3) = zDim(2); 
            end
        elseif endPosInside
            fiberOutside = 0;
            if startPos(1) < xDim(1) 
                startPos(3) = endPos(3) - (endPos(3)-startPos(3))/(endPos(1)-startPos(1))*(endPos(1)-xDim(1));
                startPos(1) = xDim(1);
            end
            if startPos(3) < zDim(1)
                startPos(1) = endPos(1) - (endPos(1)-startPos(1))/(endPos(3)-startPos(3))*(endPos(3)-zDim(1));
                startPos(3) = zDim(1); 
            end
            if startPos(1) > xDim(2)
                startPos(3) = endPos(3) - (endPos(3)-startPos(3))/(endPos(1)-startPos(1))*(endPos(1)-xDim(2));
                startPos(1) = xDim(2); 
            end
            if startPos(3) > zDim(2)
                startPos(1) = endPos(1) - (endPos(1)-startPos(1))/(endPos(3)-startPos(3))*(endPos(3)-zDim(2));
                startPos(3) = zDim(2); 
            end
        else
            if modeFlag
               plot([startPos(1) endPos(1)],[startPos(3) endPos(3)],'color','y')
            end
        end
        
        % Update the length of the fiber
        if mod(angXZ,180) > 10 && mod(angXZ,180) < 170
            lFiberProj = (endPos(3) - startPos(3))./sind(angXZ); 
        else
            lFiberProj = (endPos(1) - startPos(1))./cosd(angXZ); 
        end
    end
    
        if modeFlag == 1
           figure(E) 
           plot([startPos(1) endPos(1)],[startPos(3) endPos(3)],'g')
           print(gcf,'fiber1','-dpng','-r600')
        end   
        
    % Check that fiber is at least minFiberLength long
    if lFiberProj > physicsControl.minFiberLength
        
        % Discretization length
        divLength = elementLengthOptimization(rFiber,meshControl);
        discFreq = round(lFiberProj/divLength);
        
        if mod(discFreq,2) == 0 % Make sure we always have an uneven number of points
            discFreq = discFreq+1;
        end
        discFreqIntersectAnalysis = min(discFreq,41);
        [newLineToCheck,newLineToCheckboundingBox,discFiberCurved] = placeFiberInSpace(0,angXZ,lFiberProj,rFiber,cFiber,discFreqIntersectAnalysis,startPos);
        newLineToCheckboundingBox = [newLineToCheckboundingBox ; (depoFibers+1)*ones(1,size(newLineToCheckboundingBox,2))];     

            
        % Check that no part of the fiber is outside the bounding box.
        if max(discFiberCurved(:,1)) < xDim(2) && min(discFiberCurved(:,1)) > xDim(1) && ...
           max(discFiberCurved(:,3)) < zDim(2) && min(discFiberCurved(:,3)) > zDim(1)
       
            jBox = 1:depoFibers*6;
            
        % This loop checks for intersections and adjusts fiber locations.
        if depoFibers > 0
            % In this modified version of interX, the location of the intersection is also reported.
            % Using this information it is possible to perform a local pairwise
            % distance measurement and determine what nodes need to be raised. By
            % enforcing that only the new fiber may be moved, and that it may only be
            % moved in the positive Z direction, we are able to iteratively move the
            % most recent fiber out of the way of the existing network.
            
            % We know that each fiber is assigned only 4 segments, so it is
            % easy to figure out which of the fibers should be included in
            % the detailed intersection analysis from here. 
            %fibersTriggered = unique(mod(jBox,5));
            fibersTriggered = unique(ceil(jBox./6));
            TempExistingFibers = existingFibers(:,ismember(existingFibers(4,:),fibersTriggered)|isnan(existingFibers(4,:)));
            
            if numel(fibersTriggered) > 0
            % This is where we perform the detailed intersection analysis,
            % with the fiber hull.
            [overlapCheck,i,j] = InterXmod(newLineToCheckboundingBox([1 3],:),TempExistingFibers([1 3],:));
            
            if numel(overlapCheck) > 0
               if modeFlag==1
                   figure(E)
                   plot(existingFibers(1,:),existingFibers(3,:),'g--') 
                   plot(newLineToCheckboundingBox(1,:),newLineToCheckboundingBox(3,:),'m-+')
                   plot([newLineToCheckboundingBox(1,i) newLineToCheckboundingBox(1,i+1)],[newLineToCheckboundingBox(3,i) newLineToCheckboundingBox([3],i+1)],'ro')
                   print(gcf,'fiber2','-dpng','-r600')
               end
            
                % Here we order the intersections so that the intersection
                % with lowest z-coordinate is probed first
                [~,sortedOnY] = sort(TempExistingFibers(2,j),'ascend');    
                i = i(sortedOnY);
                j = j(sortedOnY);
                
                % Here I figure out what the size of the second fiber in
                % intersection is. I do this by counting the number of NAN
                % (fiber hull breakpoints) that exist in the matrix already.
                fiberIntersecting = zeros(size(overlapCheck,2),1);
                offsetContribution2ndFiber = zeros(size(overlapCheck,2));
                for kLoop = 1:size(overlapCheck,2)
                    fiberIntersecting(kLoop) = 1+sum(isnan(TempExistingFibers(1,1:j(kLoop))));
                    offsetContribution2ndFiber(kLoop) = fStats(fiberIntersecting(kLoop),4)+fStats(fiberIntersecting(kLoop),5);
                end
                
                fiberSize = 2*rFiber+0*tFiber;%fiberSize = 2*rFiber+2*tFiber;
                %clear fiberGap
                %size(fiberIntersecting)
                fiberGap =  fStats(fiberIntersecting(2:end),10)  - fStats(fiberIntersecting(1:end-1),10) ...
                          -(fStats(fiberIntersecting(1:end-1),4) + fStats(fiberIntersecting(1:end-1),5)) ...
                          -(fStats(fiberIntersecting(2:end),4)   + fStats(fiberIntersecting(2:end),5));
                            
                for ttLoop = 1:length(fiberGap)
                   if  fiberIntersecting(ttLoop)==fiberIntersecting(ttLoop+1)
                       fiberGap(ttLoop) = Inf;
                   end
                end
                fiberGap(end+1) = inf;  
                        
                for cLoop = 1:size(overlapCheck,2)
                % We check that the next fiber to be checked is far enough
                % away for there to be a theoretical possibility that the
                % new fiber can fit into the space.
                
                    if (fiberGap(cLoop)>fiberSize)          
                    % This part of the algorithm handles the raising of
                    % individual cross sections to some predefined level. It
                    % does this by finding the two nodes closest to the 2D
                    % projection of the contact, and then moving them
                    % upwards. 
                    distanceCheck = ones(2);
                    for aLoop = 0:1
                        for bLoop = 0:1 
                            distanceCheck(aLoop+1,bLoop+1) = sqrt((newLineToCheckboundingBox(2,i(cLoop)+aLoop)-TempExistingFibers(2,j(cLoop)+bLoop))^2);  
                        end
                    end
                    
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Diagnostics
                        if modeFlag==1
                            fprintf('%10s %10s %10s %10s\n','Min dist','rF+tF','rF2+tF2','TOT')
                            if min(min(distanceCheck)) > rFiber+tFiber+offsetContribution2ndFiber(cLoop)
                            fprintf('%10.1e %10.3e %10.3e %10.3e %10s\n',min(min(distanceCheck)),rFiber+tFiber,offsetContribution2ndFiber(cLoop),rFiber+tFiber+offsetContribution2ndFiber(cLoop),'No adjustment')
                            else
                            fprintf('%10.1e %10.3e %10.3e %10.3e %10s\n',min(min(distanceCheck)),rFiber+tFiber,offsetContribution2ndFiber(cLoop),rFiber+tFiber+offsetContribution2ndFiber(cLoop),'ADJUSTING')
                            end
                        end
                        
                        while min(min(distanceCheck)) < rFiber+tFiber+offsetContribution2ndFiber(cLoop)
                            newLineToCheckboundingBox(2,[i(cLoop):i(cLoop)+1]) = offsetContribution2ndFiber(cLoop)+0.05+rFiber+tFiber + TempExistingFibers(2,j(cLoop):j(cLoop)+1);
                            for aLoop = 0:1
                                for bLoop = 0:1
                                    distanceCheck(aLoop+1,bLoop+1) = sqrt((newLineToCheckboundingBox(2,i(cLoop)+aLoop)-TempExistingFibers(2,j(cLoop)+bLoop))^2);  
                                end
                            end 
                        end
                    
                        invIdx = true(length(newLineToCheckboundingBox),1);
                        invIdx(i(cLoop):i(cLoop)+1) = 0;

                        % If the fiber has already been raised more than
                        % this, don't raise it again.
                        if i(cLoop) ~= 1 % Take current hight from number 1
                            if newLineToCheckboundingBox(2,i(cLoop)) > newLineToCheckboundingBox(2,1)
                                newLineToCheckboundingBox(2,invIdx) = newLineToCheckboundingBox(2,i(cLoop));
                            elseif newLineToCheckboundingBox(2,i(cLoop)) < newLineToCheckboundingBox(2,1)
                                newLineToCheckboundingBox(2,i(cLoop):i(cLoop)+1) = newLineToCheckboundingBox(2,1);
                            end
                        else % Take current height from number 3
                             if newLineToCheckboundingBox(2,i(cLoop)) > newLineToCheckboundingBox(2,3)
                                newLineToCheckboundingBox(2,invIdx) = newLineToCheckboundingBox(2,i(cLoop));
                             elseif newLineToCheckboundingBox(2,i(cLoop)) < newLineToCheckboundingBox(2,3)
                                newLineToCheckboundingBox(2,i(cLoop):i(cLoop)+1) = newLineToCheckboundingBox(2,3);
                            end
                        end
                    else   

                    end

                end
                
                
                % Perform a check that all fibers are at least the minimum distance away
                % from eachother
                if modeFlag==1
                    fprintf('%60s %40s \n',[],['Final intersection check for fiber ',num2str(depoFibers+1)])
                    fprintf('%60s %10s %10s %10s %10s %10s %10s\n',[],'Fiber','NewFiber Y','OldFiber Y','Distance','Criterion','Status')
                    for dbLoop = 1:length(fiberIntersecting)
                        distTemp(dbLoop,1) = abs(newLineToCheckboundingBox(2,1) - fStats(fiberIntersecting(dbLoop),10));
                        minDistTemp = fStats(fiberIntersecting(dbLoop),4)+fStats(fiberIntersecting(dbLoop),5)+rFiber+tFiber;
                        if minDistTemp < distTemp(dbLoop,1) 
                            fprintf('%60s %10.3e %10.3e %10.3e %10.3e %10.3e %10s\n',[],fiberIntersecting(dbLoop),newLineToCheckboundingBox(2,1),fStats(fiberIntersecting(dbLoop),10),distTemp(dbLoop,1),minDistTemp,[])
                        else
                            fprintf('%60s %10.3e %10.3e %10.3e %10.3e %10.3e %10.3e\n',[],fiberIntersecting(dbLoop),newLineToCheckboundingBox(2,1),fStats(fiberIntersecting(dbLoop),10),distTemp(dbLoop,1),minDistTemp,minDistTemp-distTemp(dbLoop,1))
                        end
                    end
                    clear distTemp 
                end

            end
            end
        end
        % At this point there should be no conflicts/intersections, and we can update the centerline
        newLineToCheck(2,:) = newLineToCheckboundingBox(2,1);
        
        % Add the new fiber to the array of existing fibers for the next
        % intersection check. 
        existingFibers = [existingFibers , newLineToCheckboundingBox  , [NaN NaN NaN NaN]'];

        depoFibers = depoFibers + 1;
        
        % Calculate real length of the fiber
        lFiber = sum(sqrt(diff(newLineToCheck(1,:)).^2+diff(newLineToCheck(2,:)).^2+diff(newLineToCheck(3,:)).^2));
        
        fStats(depoFibers,:) = [depoFibers 
                                lFiberProj
                                lFiber 
                                rFiber
                                tFiber 
                                cFiber
                                (lFiber*rFiber*2*pi*tFiber)
                                (lFiber*rFiber*2*pi*tFiber)*10^-18*physicsControl.fiberDensity;
                                angXZ
                                newLineToCheckboundingBox(2,1)]';
        tTemp(depoFibers) = toc;
        currentGrammage = 1e3*sum(fStats(:,8))/(range(xDim)*1e-6*range(zDim)*1e-6);
        fprintf('Current grammage: %10.2f g/m^2. Target grammage: %10.2f g/m^2.\n',currentGrammage,physicsControl.targetGrammage)
        
        % Some plotting of the network. May be commented out for speed. Does 
        % not work well above 100 fibers. 
        if modeFlag == 1
            figure(A)
            plot3(newLineToCheck(1,:),newLineToCheck(2,:),newLineToCheck(3,:),'-','color', [0 0.4470 0.7410],'linewidth',1)
            hold on
            plot3([xDim(1) xDim(2) xDim(2) xDim(1) xDim(1)],[0 0 0 0 0],[zDim(1) zDim(1) zDim(2) zDim(2) zDim(1)],'color', [0.8500 0.3250 0.0980],'linewidth',2)
            xlabel('x'); ylabel('y'); zlabel('z');
            view([0 0]); axis equal;

            figure(B)
            plot3(newLineToCheck(1,:),newLineToCheck(2,:),newLineToCheck(3,:),'-','color', [0 0.4470 0.7410],'linewidth',1)
            hold on
            plot3([xDim(1) xDim(2) xDim(2) xDim(1) xDim(1)],[0 0 0 0 0],[zDim(1) zDim(1) zDim(2) zDim(2) zDim(1)],'color', [0.8500 0.3250 0.0980],'linewidth',2)
            xlabel('x'); ylabel('y'); zlabel('z');
            view([0 90]); axis equal

            figure(C)
            plot3(newLineToCheck(1,:),newLineToCheck(2,:),newLineToCheck(3,:),'-','color', [0 0.4470 0.7410],'linewidth',1)
            %plot3(newLineToCheck(1,:),newLineToCheck(2,:),newLineToCheck(3,:),'-','linewidth',1)
            hold on
            plot3([xDim(1) xDim(2) xDim(2) xDim(1) xDim(1)],[0 0 0 0 0],[zDim(1) zDim(1) zDim(2) zDim(2) zDim(1)],'color', [0.8500 0.3250 0.0980],'linewidth',2)
            xlabel('x'); ylabel('y'); zlabel('z');
            view([0 90])
            camup([0 1 0])
            camtarget([2000 0 2000]) 
            campos([-6000 6000 -6000])
            axis equal       
        end
        % This is the export stage of the fiber: We try to condense the information
        % into a minimum:
        % - One location set for the centerline, given by X_i, Y_i, Z_i
        % - One orientation vector N describing the axial direction of the fiber
        %   (the two other directions are equivalent for perfectly cylindrical
        %   fibers). 
        exportStructure = [exportStructure ; depoFibers*ones(size(newLineToCheck,2),2) newLineToCheck' rFiber*ones(size(newLineToCheck,2),1) tFiber*ones(size(newLineToCheck,2),1)];
        
        %figure
        if 0%1
            subplot(2,2,1)
            histogram(fStats(:,9))
            xlabel('angXY')
            
            subplot(2,2,3)
            plot(startPos(1),startPos(3),'bo')
            hold on
            plot(endPos(1),endPos(3),'sr')
            xlabel('X'); ylabel('Z');
            
            subplot(2,2,2)
            temp=histcounts2(exportStructure(2:end,3),exportStructure(2:end,5),linspace(0,8000,100),linspace(0,8000,100));
            imagesc(temp);
            
            subplot(2,2,4)%
            ksdensity([exportStructure(2:end,3),exportStructure(2:end,5)],'kernel','box','PlotFcn','contour'); %'reflection' % ,'boundaryCorrection','log','support',[-1 -1 ; 8001 8001],
            xlim([0 8000]); ylim([0 8000])
            colorbar;
            caxis([0 3e-8])


            if mod(depoFibers,10)==0
                pause(0.2)
            end
        end
        end
    end
end


minY = min(exportStructure(:,4)-exportStructure(:,6)-exportStructure(:,7)/2);
maxY = max(exportStructure(:,4)+exportStructure(:,6)+exportStructure(:,7)/2);

yDim = maxY-minY;

% Export the information necessary to create the new structure in ANSYS. 
csvwrite('centerLines.csv',exportStructure)

% Register and archive the specific network
uuid = char(java.util.UUID.randomUUID); % Pseudo-unique identifier
fileName.networkSaveName= horzcat(datestr(date),'_',uuid,'.mat');
save(fileName.networkSaveName,'exportStructure','physicsControl','meshControl','furnishControl')
fprintf('Network is saved as %s\n',fileName.networkSaveName)
