function maxElFib = recutNetwork_v2(nodalFile,elementFile,xRange,zRange)

origNodes = importNodes(nodalFile);
origElements = importElements_v2(elementFile);

maxElFib=max(origElements(:,2));

newNodes = origNodes;
size(origNodes)
newNodes(newNodes(:,2)<xRange(1),:) = [];
newNodes(newNodes(:,2)>xRange(2),:) = [];
newNodes(newNodes(:,4)<zRange(1),:) = [];
newNodes(newNodes(:,4)>zRange(2),:) = [];
size(newNodes)

% Plot the state
if 0
    figure();
    plot(origNodes(:,2),origNodes(:,4),'o')
    hold on
    plot([xRange(1) xRange(2) xRange(2) xRange(1) xRange(1)],[zRange(1) zRange(1) zRange(2) zRange(2) zRange(1)],'-r')
    plot(newNodes(:,2),newNodes(:,4),'s')
    hold on
    axis equal
end
% figure();
% plot3(origNodes(:,2),origNodes(:,3),origNodes(:,4),'o')
% axis equal

% Decide whether to check against matrix of nodes INSIDE or OUTSIDE of the
% box (always check against the smallest list!)
newElements = origElements;
retainedNodesSize = size(origNodes,1);
%droppedNodesSize = size(origNodes,1)-retainedNodesSize;




% If Clause removed due to performance increase + did not want to do
% extensive testing of inversion case.

% if droppedNodesSize < retainedNodesSize
%     droppedNodes = setdiff(origNodes(:,1),newNodes(:,1));
%     toggleSwitch = -1;
%     chckNodes = droppedNodes;
%     nodeArray = nan(max(chckNodes(:,1)),4);
%     nodeArray(chckNodes(:,1),:) = origNodes(droppedNodes,:);
% else
    toggleSwitch = 1;
    chckNodes = origNodes(:,1);%newNodes(:,1);
    nodeArray = nan(max(chckNodes(:,1)),4);
    nodeArray(newNodes(:,1),:) = newNodes;
% end


% Go through all of the elements and make sure there are no elements with
% incomplete nodal connectivity.

remIdx = false(size(newElements,1),1); % Pre-allocate
remIdxNodes = false(size(nodeArray,1),1);
for aLoop = 1:size(newElements,1)
    eToCheck = newElements(aLoop,:); % Select 1 element
    try
    if isnan(nodeArray(eToCheck(3),1)) || isnan(nodeArray(eToCheck(4),1)) || isnan(nodeArray(eToCheck(5),1)) || isnan(nodeArray(eToCheck(6),1))
        cond1 = 1;
    else
        cond1 = 0;
    end
    catch
        disp(stop)
    end
%     
%     n1Exists = ismember(eToCheck(3:6),chckNodes);
%     n2Exists = n1Exists(2); 
%     n3Exists = n1Exists(3); 
%     n4Exists = n1Exists(4);
%     n1Exists = n1Exists(1);
%     


    if toggleSwitch == 1
        if cond1%n1Exists*n2Exists*n3Exists*n4Exists==0%   length(n1Exists)*length(n2Exists)*length(n3Exists)*length(n4Exists) == 0 %if one node is cut out, cut out the whole element
            remIdx(aLoop) = true; %record the position where the element need to be deleted (aloop: position of the element)
            
            remIdxNodes(eToCheck(3:6)) = true; % Doesn't work, nodes may be connected to other stuff.
            
        end
    else
        if n1Exists*n2Exists*n3Exists*n4Exists==0%n1Exists+n2Exists+n3Exists+n4Exists>0%   length(n1Exists)*length(n2Exists)*length(n3Exists)*length(n4Exists) == 0 %if one node is cut out, cut out the whole element
            remIdx(aLoop) = true; %record the position where the element need to be deleted (aloop: position of the element)
        end
    end
end


newElements(remIdx,:) = []; %cancella gli elementi che hanno remIdx=true
newElements(:,1) = 1:size(newElements,1); 



newSel = ismember(nodeArray(:,1),unique(reshape(newElements(:,3:6),[],1)));

remNodes = boolean(ones(size(nodeArray,1),1));
remNodes(newSel) = false;

nodeArray(remNodes,:) = [];
nodeArray(isnan(nodeArray(:,1)),:) = [];

%size(nodeArray)

newNodes = nodeArray;



% Push the result to file
% Nodes
fileID = fopen(nodalFile,'w');
fprintf(fileID,'%s \n','*NODES');
fprintf(fileID,'%8d %+14.8e %+14.8e %+14.8e\n',newNodes');
fclose(fileID);

fileID = fopen(elementFile,'w');
fprintf(fileID,'%s \n','*ELEMENT_SHELL');
fprintf(fileID,'%8d%8d%8d%8d%8d%8d\n',newElements');
fclose(fileID);