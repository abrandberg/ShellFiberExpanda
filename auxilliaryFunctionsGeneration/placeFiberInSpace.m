function [newLineToCheck,newLineToCheckboundingBox,discFiberCurved] = placeFiberInSpace(testFlag,angXZ,lFiber,rFiber,curvature,discFreq,startPos)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 1:
%   angXZ = 0;
%   lFiber = 100;
%   rFiber = 12;
%   curvature = 0;
%   discFreq = 100;
%   startPos = [0 0];

if nargin == 1
    if testFlag ~= 1
        [angXZ,lFiber,rFiber,curvature,discFreq,startPos]= testData(testFlag);
    end
end


rotationalMatrix = [cosd(angXZ) 0 sind(angXZ) ; 0 1 0 ; -sind(angXZ) 0 cosd(angXZ)];

discXC = linspace(0,lFiber,discFreq)';
discX = linspace(0,lFiber,min(discFreq,21))';
discFiberCurved = startPos + [discXC zeros(size(discXC)) curvature*lFiber*sin(pi*discXC/(lFiber))]*rotationalMatrix;


newLineToCheck = [discFiberCurved(:,1)' ; zeros(size(discFiberCurved(:,1)')) ; discFiberCurved(:,3)'];

% New part implementing the bounding box solution method
discFiberCurved5 = startPos - rFiber*[cosd(angXZ+90) 0 sind(angXZ+90)] ...
                   + [discX zeros(size(discX)) curvature*lFiber*sin(pi*discX/(lFiber))]*rotationalMatrix;
discFiberCurved6 = flip(startPos + rFiber*[cosd(angXZ+90) 0 sind(angXZ+90)] + [discX zeros(size(discX)) curvature*lFiber*sin(pi*discX/(lFiber))]*rotationalMatrix);
discFiberCurved56 = [discFiberCurved5(end,:) ; discFiberCurved6(1,:) ];
discFiberCurved65 = [discFiberCurved6(end,:) ; discFiberCurved5(1,:) ];
stackedFiberContour = [discFiberCurved5 ; discFiberCurved56 ; discFiberCurved6 ; discFiberCurved65];

newLineToCheckboundingBox = stackedFiberContour';

% If testing, show result
if testFlag ~= 0
    figure();
    plot(newLineToCheck(1,:),newLineToCheck(3,:));
    hold on
    plot(newLineToCheckboundingBox(1,:),newLineToCheckboundingBox(3,:));
    xlabel('x'); ylabel('z');
    axis equal
end

end

function [angXZ,lFiber,rFiber,curvature,discFreq,startPos]= testData(testFlag)

switch testFlag

    case 1 % Straight fiber, oriented along the axis X
        angXZ = 0;
        lFiber = 100;
        rFiber = 12;
        curvature = 0;
        discFreq = 100;
        startPos = [0 0 0];    
    case 2 % Straight fiber, oriented at an angle of 30 degrees to the X axis
        angXZ = 30;
        lFiber = 100;
        rFiber = 12;
        curvature = 0;
        discFreq = 100;
        startPos = [0 0 0];    
    case 3
        angXZ = 0;
        lFiber = 100;
        rFiber = 12;
        curvature = 1/2;
        discFreq = 100;
        startPos = [0 0 0];  
end
end
