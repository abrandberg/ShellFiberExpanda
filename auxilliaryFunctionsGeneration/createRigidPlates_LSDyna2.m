function [solidNodalData,solidElementData] = createRigidPlates_LSDyna2(cLines,nodalData,shellElementData,meshControl)
% Here is we bind together the element data
%
%     +----------+
%     |          |
%     |          |
%     +----------+
%
% Meshing strategy: 
%  - Bottom layer first, top layer second.
%  - Number of nodes along x is given by xGrid
%  - Number of nodes along z is given by zGrid
%
% Using indexes aLoop for xGrid
%               bLoop for zGrid
%               cLoop for yGrid
% the ordering of nodes to be tied is the following
%
% FROM 0:ALOOP-2
%     FROM 1:BLOOP
%         element = [idx 1 1+xGrid 1+xGrid+zGrid xGrid+zGrid ...
%                        xGrid*zGrid+1 ]
%
% FIRST ROUND:
%                IKP JKP KKP LKP MKP NKP OKP PKP
%                  1   3  49  47   2   4  48  50
% SECOND ROUND:
%                  3   5  

% CONSTRUCTING THE RIGID PLATES.


% Find the max values in all dimensions
minX = min(cLines(:,2));
maxX = max(cLines(:,2));
minY = min(cLines(:,3)-cLines(:,5)-cLines(:,6)/2);
maxY = max(cLines(:,3)+cLines(:,5)+cLines(:,6)/2);
minZ = min(cLines(:,4));
maxZ = max(cLines(:,4));

% Find the top and the bottom fiber
xPlateSize = max((maxX-minX)*1.2,100); % If the size is too small, make it at least 100 um wide
zPlateSize = max((maxZ-minZ)*1.2,100);
xPlateMid = (maxX+minX)/2;
zPlateMid = (maxZ+minZ)/2;

% Discretize
xGrid = linspace(xPlateMid-xPlateSize,xPlateMid+xPlateSize,ceil(xPlateSize/meshControl.plateElementSize));
yGridBttm = linspace(0,meshControl.plateElementHeight,2);
yGridTop = linspace(meshControl.plateElementHeight,0,2);
zGrid = linspace(zPlateMid-zPlateSize,zPlateMid+zPlateSize,ceil(zPlateSize/meshControl.plateElementSize));

[XB,YB,ZB] = meshgrid(xGrid,yGridBttm,zGrid);
[XT,YT,ZT] = meshgrid(xGrid,yGridTop,zGrid);
xLength = length(xGrid);
zLength = length(zGrid);
XT = reshape(XT,numel(XT),1);
XB = reshape(XB,numel(XB),1);
YB = reshape(YB,numel(YB),1);
YT = reshape(YT,numel(YT),1);
ZT = reshape(ZT,numel(ZT),1);
ZB = reshape(ZB,numel(ZB),1);
nodeOffset = max(nodalData(:,1));
solidNodalData = [nodeOffset+[1:numel(XT)]'            XT maxY+YT ZT ;   % Nodes for the top plate
                  nodeOffset+[numel(XB)+1:2*numel(XB)]' XB minY-YB ZB];   % Nodes for the bottom plate

counter = 1;

solidElementData = zeros((zLength-1)*(xLength-1),10);
eOffset = max(shellElementData(:,1));
%figure();
for bLoop = 0:zLength-2%2      % Then for 1 x, 
  for cLoop = 1:xLength-1   % do all the z-coordinates

      ikp = 2*xLength*bLoop + 2*cLoop-1;
      jkp = 2*xLength*bLoop + 2*cLoop+1;
      kkp = 2*xLength*(bLoop+1) + 2*cLoop+1;
      lkp = 2*xLength*(bLoop+1) + 2*cLoop-1;

      mkp = ikp+1;
      nkp = jkp+1;
      okp = kkp+1;
      pkp = lkp+1;
        
      solidElementData(counter,:) = [counter+eOffset 2 ikp+nodeOffset ...
                                                                             jkp+nodeOffset ...
                                                                             kkp+nodeOffset ...
                                                                             lkp+nodeOffset ...
                                                                             mkp+nodeOffset ...
                                                                             nkp+nodeOffset ...
                                                                             okp+nodeOffset ...
                                                                             pkp+nodeOffset];
%            patch('XData',solidNodalData([ikp jkp kkp lkp],2),...
%                  'YData',solidNodalData([ikp jkp kkp lkp],3),...
%                  'ZData',solidNodalData([ikp jkp kkp lkp],4),...
%                  'FaceColor','red')%,'FaceAlpha',0.3
%             hold on
%            patch('XData',solidNodalData([mkp nkp okp pkp],2),...
%                  'YData',solidNodalData([mkp nkp okp pkp],3),...
%                  'ZData',solidNodalData([mkp nkp okp pkp],4),...
%                  'FaceColor','blue')%,'FaceAlpha',0.3          
%         %  elementDataSolid(counter,:) = [counter ikp jkp kkp lkp mkp nkp okp pkp];
%           xlabel x; ylabel y; zlabel z;

        counter = counter + 1;
  end
end

solidElementDataBottom = solidElementData;
solidElementDataBottom(:,1) = solidElementData(:,1)+counter;
solidElementDataBottom(:,2) = 3;
solidElementDataBottom(:,3:10) = solidElementData(:,3:10)+numel(XB);

solidElementData = [solidElementData ;
                   solidElementDataBottom];

