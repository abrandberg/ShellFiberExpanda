function partList = contactFormulationShellRestart_v2(partList,elementsInModel)
% Steps to implement
% 1. Import nodes
% 2. Import elements
% 3. Reassemble the parts, consisting of all nodes belonging to each fiber.
% 4. FOR each part
%       FOR each part not examined yet
%          Compare the pairwise distance from all nodes to all nodes
%          Save the minimum distance found
%          IF minimum distance < threshold distance
%               Create contact formulation for that pair of parts
%          ELSE 
%               Do nothing
%    Remove the part from the list of parts to compare against.

Fibers = unique([partList.partNumber]);%unique(elementsInModel(:,2));
Fibers(isnan(Fibers)) = [];
numFibers = length(Fibers);

contactThreshold = 40; % um
cCreated = 0;
NOcCreated = 0;


% Calculate the minimum distance between the different parts
for bLoop = 1:numFibers
    partList(bLoop).contactList = nan(numFibers-bLoop,1);
    cIdx = 1;
    
        minX1 = min(partList(bLoop).nodalCoordinates(:,1)) - contactThreshold;
        maxX1 = max(partList(bLoop).nodalCoordinates(:,1)) + contactThreshold;
        minY1 = min(partList(bLoop).nodalCoordinates(:,2)) - contactThreshold;
        maxY1 = max(partList(bLoop).nodalCoordinates(:,2)) + contactThreshold;        
        minZ1 = min(partList(bLoop).nodalCoordinates(:,3)) - contactThreshold;
        maxZ1 = max(partList(bLoop).nodalCoordinates(:,3)) + contactThreshold;     
        
    tic;
    for cLoop = bLoop+1:numFibers 
        % Calculate the pointwise distance to all other fibers, in sequence.
        
        % "Simple box search"   
        minX2 = min(partList(cLoop).nodalCoordinates(:,1)) - contactThreshold;
        maxX2 = max(partList(cLoop).nodalCoordinates(:,1)) + contactThreshold;
        minY2 = min(partList(cLoop).nodalCoordinates(:,2)) - contactThreshold;
        maxY2 = max(partList(cLoop).nodalCoordinates(:,2)) + contactThreshold;        
        minZ2 = min(partList(cLoop).nodalCoordinates(:,3)) - contactThreshold;
        maxZ2 = max(partList(cLoop).nodalCoordinates(:,3)) + contactThreshold;      
        
        condition1 = (maxX1<minX2 || maxX2<minX1);
        condition2 = (maxY1<minY2 || maxY2<minY1);
        condition3 =  (maxZ1<minZ2 || maxZ2<minZ1);

        finalCondition = condition1 || condition2 || condition3;
        
        if not(finalCondition)
            smallestDistance = sqrt(min(pdist2([partList(bLoop).nodalCoordinates], ...
                                               [partList(cLoop).nodalCoordinates],'squaredeuclidean','Smallest',1)));

            if 0
                figure();
                plot3(partList(bLoop).nodalCoordinates(:,1),partList(bLoop).nodalCoordinates(:,2),partList(bLoop).nodalCoordinates(:,3),'o')
                xlabel x; ylabel y; zlabel z; axis equal
                hold on
                plot3(partList(cLoop).nodalCoordinates(:,1),partList(cLoop).nodalCoordinates(:,2),partList(cLoop).nodalCoordinates(:,3),'s')
                pause(0.1)
            end

            if smallestDistance < contactThreshold
                cCreated = cCreated+1;
                partList(bLoop).contactList(cIdx) = partList(cLoop).partNumber;
                cIdx = cIdx + 1 ;
            else
                NOcCreated = NOcCreated+1;
            end        
        else
            NOcCreated = NOcCreated+1;
        end

        
    end
    fprintf('Looking at fiber %6d out of %6d . Contacts/All is  %4.2f per cent.\n',bLoop,numFibers,100*round(cCreated/(cCreated+NOcCreated),4))
    
    % Clean up the structure, removing nans
    nanIdx = isnan(partList(bLoop).contactList);
    partList(bLoop).contactList(nanIdx) = [];
    
    
    tTemp(bLoop) = toc;
    % Output some statistics
    if 0
        if bLoop == 1
           figure();
           xlabel('Fiber'); ylabel('Time to search [s]'); 
           hold on
        elseif mod(bLoop,10) == 0
            plot(bLoop,tTemp(bLoop),'ob')
            hold on
            pause(0.1)
        end

    end
end


