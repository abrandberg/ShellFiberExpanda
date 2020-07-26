function [condensedData,restoreGeom] = postProcessingGeometry_v2(nodes,elements,ctrl,nodeCountRadius,restoreGeom)

if nargin == 4
    restoreGeom = struct('a',[]);
    %restoreGeom = struct('selRing',[]);
end
    

% First step, check if boolean reconstruction has already been performed.
if isfield(restoreGeom,'selRing') % If node rings were already reconstructed, use them    
    reconstructRings = 0;
    disp('-----> Previously reconstructed rings exist.')
    %disp('       Preprocessing saved data')
    %size(restoreGeom(

    
else % Fall back on old calculation method
    reconstructRings = 1;
    disp('-----> No data in input, will reconstruct autonomously.')
end
try
    restoreGeom = rmfield(restoreGeom,'a');
end

nodesOrig = nodes;
missingNodes = setdiff(1:max(nodes(:,1)),nodes(:,1));

    disp(['       ',num2str(numel(missingNodes)),' nodes missing from the list.'])
    if numel(missingNodes) > 0
        nanNodes = nan(numel(missingNodes),4);
        nanNodes(:,1) = missingNodes';
        nodes = [nodes ; nanNodes];
        % Sort
        [~,nIdx] = sort(nodes(:,1));
        nodes = nodes(nIdx,:);
    end
    
% Initialize
% nodeCountRadius = 16;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start of the main code loop
if ctrl.plotMode
    fig2 = figure('name','histogramPlotter');
end
    
% Preallocate
sIdx = 1;
fibers = unique(elements(:,2));
fibers(isnan(fibers)) = [];

fibers(fibers==2,:) = [];
fibers(fibers==3,:) = [];


% disp('----> Entering main loop.')


for xLoop = fibers' % For every fiber
    
    if reconstructRings
        % Zero the length of some values in preparation for reassignment.
        ringTemp = [];   
        collNodes = [];

        % 1. Select all elements belonging to the fiber
        selIdx = elements(:,2) == xLoop;
        elementsInSet = elements(selIdx,:);

        % 2. Select all nodes belonging to the fiber 
        nodeNumbersInSet = unique(elementsInSet(:,3:6));
        bolIdxNodes = ismember(nodes(:,1),nodeNumbersInSet);
        nodesInSet = nodes(bolIdxNodes,:);

        if ctrl.plotMode
            figure();
            scatter3(nodes(bolIdxNodes,2),nodes(bolIdxNodes,3),nodes(bolIdxNodes,4),'.')
            axis equal; hold on
            xlabel x; ylabel y; zlabel z;
        end
        if ctrl.verbose
            disp('          N.B. You are running the code in non-safe mode')
        end
    end   
    
    
    yLoop = 1;
        
    while yLoop > 0
        if reconstructRings
            oldConnectedElements = max(ismember(elementsInSet(:,3:6),collNodes),[],2);
            oldElements = elementsInSet(oldConnectedElements,:);

            % The minimum node number can not be guaranteed to be on one of the
            % edges of the cylinder. Hence, we limit the search to endpoints during
            % the first iteration (yLoop == 1)  
            if yLoop == 1
                pTEMP = histcounts(elementsInSet(:,3:6),nodesInSet(:,1))==2; % Add a clause about == 1?
                ringTemp = min(nodesInSet(pTEMP,1));
            else
                ringTemp = min(setdiff(nodesInSet(:,1),collNodes));
            end

            counter = 0;
            ringTempOld = [];
            addedNodes = setdiff(ringTemp,ringTempOld);

            % While to find each "ring"
            while counter < length(ringTemp)
                connectedElements = max(ismember(elementsInSet(:,3:6),addedNodes),[],2);
                newElements = elementsInSet(connectedElements,:); % Elements connected to the chosen nodes

                for aLoop = 1:size(newElements,1)
                    nodesToCheck = unique(newElements(aLoop,3:6)); % Gives the node numbers (but not indices!) to check

                    for bLoop = 1:length(nodesToCheck)
                        numConnect =  max(elementsInSet(:,3:6) == nodesToCheck(bLoop),[],2);
                        tempElements = elementsInSet(numConnect,:);

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % This logic probably needs to be rewritten all together for the destroyed mesh to me admissible.
                        % If the node is already in ringTemp, do not add it again.
                        if sum(nodesToCheck(bLoop) == ringTemp) > 0
                            % Do nothing
                        elseif size(elements(setdiff(tempElements(:,1),oldElements(:,1))),1) == 2 
                            ringTemp = [ringTemp ; nodesToCheck(bLoop)]; % Add the node to the list                          
                        end
                    end
                end
                counter = counter + 1;
                addedNodes = setdiff(ringTemp,ringTempOld);
                ringTempOld = ringTemp;
            end

            bolSelringTempOld = ismember(nodes(:,1),ringTempOld);
            if ctrl.verbose
                disp(['          ',num2str(counter),' nodes were added to the ring. Expected ',num2str(nodeCountRadius),'.'])
            end
            numInRing = length(ringTemp);
        else
            %ringTemp = 100; % OBS only to enter the next IF clause
%             nTemp = restoreGeom(sIdx).selRing(yLoop).list;
            % Find correct index
            listTemp = [restoreGeom.fiber];
            indexToLoad = find(xLoop==listTemp,1);
            try
            nTemp = restoreGeom(indexToLoad).selRing(yLoop).list;
            catch
                %disp(stop)
                nTemp = nan(12,4);
                nTemp(:,1) = 1:12;
            end
            nTemp = [nTemp(:,1) nodes(nTemp(:,1),2:4)];
            %bolSelringTempOld = zeros(size(nodes,1),1);
            bolSelringTempOld = false(size(nodes,1),1);
            bolSelringTempOld(nTemp(:,1)) = true;
            %bolSelringTempOld = logical(bolSelringTempOld);
            numInRing = size(nTemp,1);
        end
        
        if reconstructRings
            restoreGeom(sIdx).fiber = xLoop;
            restoreGeom(sIdx).selRing(yLoop).list = nodes(bolSelringTempOld,:);
            nTemp = nodes(bolSelringTempOld,:);
        end
        
    % This part should be done regardless of how the geometry was found.
        if numInRing > 1
            condensedData(sIdx).fiber = fibers(sIdx); % Fiber unique identifier
            
            if mod(numInRing,nodeCountRadius) == 0 && sum(sum(isnan(nTemp)))==0
                if ctrl.verbose
                    disp('          Ring appears whole. Adding.')
                end

                if reconstructRings
                    [~,EigCordsDefCross] = pca(nodes(bolSelringTempOld,2:4));
                    condensedData(sIdx).midLine(yLoop,:) = [mean(nodes(bolSelringTempOld,2)) ...
                                                            mean(nodes(bolSelringTempOld,3)) ...
                                                            mean(nodes(bolSelringTempOld,4))] ; % Calculate midline
                else
                    [~,EigCordsDefCross] = pca(nTemp(:,2:4));
                    condensedData(sIdx).midLine(yLoop,:) = [mean(nTemp(:,2)) ...
                                                            mean(nTemp(:,3)) ...
                                                            mean(nTemp(:,4))] ; % Calculate midline
                end
                condensedData(sIdx).width(yLoop) = range(EigCordsDefCross(:,1));
                try
                    condensedData(sIdx).height(yLoop) = range(EigCordsDefCross(:,2));
                catch
                    disp(stop)
                end
   
            else
                if ctrl.verbose
                    disp('          Ring appears broken. Please check results carefully.')
                end
                    
                condensedData(sIdx).midLine(yLoop,:) = nan(1,3); % Calculate midline
                condensedData(sIdx).width(yLoop) = nan;
                condensedData(sIdx).height(yLoop) = nan;
            end
            
            if ctrl.plotMode
                scatter3(nodes(bolSelringTempOld,2),...
                nodes(bolSelringTempOld,3),...
                nodes(bolSelringTempOld,4),'s','filled')
                axis equal; hold on
                scatter3(nodes(bolSelringTempOld(1),2),...
                nodes(bolSelringTempOld(1),3),...
                nodes(bolSelringTempOld(1),4),'sk','filled') % First node in set
                plot3(condensedData(sIdx).midLine(yLoop,1), ...
                      condensedData(sIdx).midLine(yLoop,2), ...
                      condensedData(sIdx).midLine(yLoop,3),'rs')
                pause(0.5);
            end
            
        else
            condensedData(sIdx).fiber = fibers(sIdx);
            condensedData(sIdx).midLine = nan(3,3);
        end
        
        if reconstructRings
            collNodes = [collNodes ; ringTemp];
        
        
            if isempty(setdiff(nodesInSet(:,1),collNodes))
                yLoop = -1;
            else
                yLoop = yLoop + 1;
            end
        else
            try
                if yLoop == numel(restoreGeom(indexToLoad).selRing)
                    yLoop = -1;
                else
                    yLoop = yLoop + 1;
                end            
            catch
                yLoop = -1;
            end
        end
           
    end
    
    % Find the indices that are non-nan
%     try

    nanIdx = not(isnan(condensedData(sIdx).midLine(:,1))) & not(condensedData(sIdx).midLine(:,1)== 0);
    firstCSIdx = find(nanIdx,1,'first');
    lastCSIdx = find(nanIdx,1,'last');
%     catch
%         disp(stop)
%     end
    
    
    
    % Calculate KPIs for the geometry
    condensedData(sIdx).Lc = sum(sqrt(diff(condensedData(sIdx).midLine(nanIdx,1)).^2 + ...
                                      diff(condensedData(sIdx).midLine(nanIdx,2)).^2 + ...
                                      diff(condensedData(sIdx).midLine(nanIdx,3)).^2));
    condensedData(sIdx).Lp = sum(sqrt(diff(condensedData(sIdx).midLine([firstCSIdx lastCSIdx],1)).^2 + ...
                                      diff(condensedData(sIdx).midLine([firstCSIdx lastCSIdx],2)).^2 + ...
                                      diff(condensedData(sIdx).midLine([firstCSIdx lastCSIdx],3)).^2));
    condensedData(sIdx).widthMean = mean(condensedData(sIdx).width(nanIdx));
    condensedData(sIdx).heightMean = mean(condensedData(sIdx).height(nanIdx));
    
    condensedData(sIdx).widthStd = std(condensedData(sIdx).width(nanIdx));
    condensedData(sIdx).heightStd = std(condensedData(sIdx).height(nanIdx));
    
    if ctrl.plotMode
        figure(fig2);
        subplot(2,6,1)
        histogram([condensedData(:).Lc])
        title('Real length'); xlabel('Length [\mu m]'); ylabel('Observations')
        subplot(2,6,2)
        histogram([condensedData(:).Lp])
        title('Projected length'); xlabel('Length [\mu m]'); ylabel('Observations')
        subplot(2,6,3)
        histogram([condensedData(:).widthMean])
        title('Width'); xlabel('Width [\mu m]'); ylabel('Observations')
        subplot(2,6,7)
        histogram([condensedData(:).heightMean])
        title('Height'); xlabel('Height [\mu m]'); ylabel('Observations')
        subplot(2,6,8)
        histogram([condensedData(:).Lc]./[condensedData(:).Lp]-1)
        title('Curl'); xlabel('Curl Lc/Lp-1 [-]'); ylabel('Observations')
        subplot(2,6,9)
        histogram([condensedData(:).heightMean]./[condensedData(:).widthMean])
        title('Aspect Ratio'); xlabel('Height / Width [-]'); ylabel('Observations')

        subplot(1,2,2)
        plot3(condensedData(sIdx).midLine(nanIdx,1), ...
              condensedData(sIdx).midLine(nanIdx,2), ...
              condensedData(sIdx).midLine(nanIdx,3),'b-')
        hold on
        xlabel('x [\mum]'); ylabel('y [\mum]'); zlabel('z [\mum]');  axis equal
   
        if mod(sIdx,50) == 0
            title([num2str(xLoop) ' out of ' num2str(size(fibers,1)) ' fibers.'])
            pause(0.5)
        end
    end
    if mod(sIdx,500) == 0
        disp(['          Fiber ' num2str(sIdx) ' / ' num2str(length(fibers)) ' complete.'])
    end
    sIdx = sIdx + 1;
end    
 
% disp('----> Exiting main loop.')
% At this point the data is complete and can be saved
% if ctrl.saveOutputOnExit
%     save(horzcat('output_',inputFileString(7:end)),'condensedData')
%     disp(['Output was saved in .MAT format with tag ' horzcat('output_',inputFileString(7:end)) '.'])
% end





