function [nodalData] = createNodalData_LSDyna(cLines,meshControl)
%function createNodalData_LSDyna(cLines,meshControl) is used to create the nodal mesh of
%the network in the reference configuration. The inputs are the centerpoints of individual
%fiber cross-sections, as well as the structure meshControl which contains all types of
%data regarding mesh density, etc. See the main function for more information about
%meshControl.
%
% INPUTS:       cLines
%               meshControl
%
% OUTPUTS:      nodalData
%
% ABOUT:
%
% TO DO:
%
%
% created by:   August Brandberg augustbr at kth . se
% date:         26-10-2019

% Create a matrix with the directional vectors from one center point to the
% next.
dLines = diff(cLines(:,2:4));
dLines = [cLines(1:end-1,1) dLines];
dLines(dLines(1:end-1,1)~=dLines(2:end,1),2:4) = NaN;
nanIdxs = isnan(dLines(:,2));
dLines(isnan(dLines(:,2)),2:4) = dLines([nanIdxs(2:end) ; false],2:4);
dLines(end+1,:) = dLines(end,:);

% Normalize dLines
for xLoop = 1:size(dLines,1)
   dLines(xLoop,2:4) =  dLines(xLoop,2:4)/norm(dLines(xLoop,2:4));
end
cFiberOld = 1;
% For each center point, create a local coordinate system and a set of
% nodes around it, all at the distance Rmid away

% Hence, we need to create a cylindrical coordinate system with its origo in the
% centerpoint, and the Z direction aligned with the dLines data.

nodalData = zeros(size(cLines,1)*meshControl.aDiv,3);
angDisc = linspace(0,360,meshControl.aDiv+1)';   
angDisc = angDisc(1:end-1);              % Drop final entry since we will tie back into the first.

%figure();
cRowTemp = 1;
for yLoop = 1:size(cLines,1)
%     currentFiber = sum(isnan(dLines(1,:)));
%     fprintf('Meshing fiber number %10d .',currentFiber)
    
   radiusTemp = cLines(yLoop,5);
   startPos   = cLines(yLoop,2:4); 
   zAxisTemp  = dLines(yLoop,[2 4]);
  
   localCoordinates = radiusTemp*[cosd(angDisc) sind(angDisc) zeros(size(angDisc))];
   angXZ = mod(atan2d(zAxisTemp(2),zAxisTemp(1))+360,360);

   if 0%1
      close all;
      figure();
      % Plot the centerpoints of this iteration and the next of yLoop
      plot(cLines(yLoop,2),cLines(yLoop,4),'o')
      hold on
      plot(cLines(yLoop+1,2),cLines(yLoop+1,4),'o')
      plot(cLines(yLoop:yLoop+1,2),cLines(yLoop:yLoop+1,4),'-.','color','k')
      xlabel('x [um]') ; ylabel(' z [um]'); axis equal
       
   end
   
   
   clear globalCoordinates
   for vLoop = 1:size(localCoordinates,1)
         globalCoordinates(vLoop,:) = startPos + transpose(([cosd(90-angXZ) 0 sind(90-angXZ) ; 0 1 0 ; -sind(90-angXZ) 0 cosd(90-angXZ)]*localCoordinates(vLoop,:)'));
   end
   
   nRowsTemp = size(globalCoordinates,1);
   nodalData(cRowTemp:cRowTemp+nRowsTemp-1,:) = globalCoordinates;% = [nodalData ; globalCoordinates];
   cRowTemp = cRowTemp + nRowsTemp;
   
   if 0%1
       plot(startPos(1)+localCoordinates(:,1),startPos(3)+localCoordinates(:,3),'+')
       plot(globalCoordinates(:,1),globalCoordinates(:,3),'s') 
       
       plot(globalCoordinates2(:,1),globalCoordinates2(:,3),'^') 
       plot(globalCoordinates3(:,1),globalCoordinates3(:,3),'+') 
       legend('Node 1','Node 2','Vector connecting them','REF','G1','G2','G3','location','bestOutside')
       title(['Angle is ',num2str(angXZ) ])
   end
      
%    scatter3(startPos(1),startPos(2),startPos(3),'r')
%    hold on
%    scatter3(globalCoordinates(:,1),globalCoordinates(:,2),globalCoordinates(:,3),'b')
%    axis equal 
%    pause(0.1);
%    
%    cFiber = cLines(yLoop,1);
%    if cFiber ~= cFiberOld
%        hold off
%    end
%    cFiberOld = cFiber;

end

nodalData = [[1:size(nodalData,1)]' nodalData]; % Append node index numbers






