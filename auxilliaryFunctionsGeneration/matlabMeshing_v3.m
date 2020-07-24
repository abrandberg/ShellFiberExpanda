function matlabMeshing_v3(meshControl,physicsControl,modeFlag)
%
% Import the centerlines.csv file
cLines = csvread('centerLines.csv');

% Remove extra data needed for the ANSYS script
cLines = cLines(2:end,2:end);
if modeFlag ==1
    f=figure();
    set(f,'renderer','opengl');
    for xLoop = 1:max(cLines(:,1))
        plot3(cLines(cLines(:,1)==xLoop,2),cLines(cLines(:,1)==xLoop,3),cLines(cLines(:,1)==xLoop,4))
        hold on
%         quiver3(cLines(cLines(:,1)==xLoop,2),cLines(cLines(:,1)==xLoop,3),cLines(cLines(:,1)==xLoop,4), ...
%                 dLines(dLines(:,1)==xLoop,2),dLines(dLines(:,1)==xLoop,3),dLines(dLines(:,1)==xLoop,4))
    end
    xlabel('x'); ylabel('y'); zlabel('z');
    axis equal
end


% Create shell element data
disp('          -> CREATING NODAL CONNECTIVITY DATA')
shellElementData = createShellElementData_LSDyna(cLines,meshControl);


% Create the nodal data
disp('          -> CREATING NODAL DATA')
nodalData = createNodalData_LSDyna(cLines,meshControl);
disp('          -> CREATING RIGID PLATES')
[solidNodalData,solidElementData] = createRigidPlates_LSDyna2(cLines,nodalData,shellElementData,meshControl);
% Write the nodal data to file
geometryInputFile = 'file.k';
fileID = fopen(geometryInputFile,'at');
fprintf(fileID,'%s\n','*KEYWORD');
fprintf(fileID,'%s\n%s\n','*DATABASE_FORMAT','         0');
fprintf(fileID,'%s\n','*NODE');
fprintf(fileID,'%8d%16.9E%16.9E%16.9E%8d%8d\n',[nodalData zeros(size(nodalData,1),2)]');
fprintf(fileID,'%8d%16.9E%16.9E%16.9E%8d%8d\n',[solidNodalData zeros(size(solidNodalData,1),2)]');
fclose(fileID);


% Write the shell element data to file
fileID = fopen(geometryInputFile,'at');
fprintf(fileID,'%s\n','*ELEMENT_SHELL');
fprintf(fileID,'%8d%8d%8d%8d%8d%8d\n',shellElementData');
fprintf(fileID,'%s\n','*ELEMENT_SOLID');
fprintf(fileID,'%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d\n',solidElementData');
fclose(fileID);

disp('          -> CREATING SECTION DATA')
% Write the part data to file
fileID = fopen(geometryInputFile,'at');

fprintf(fileID,'%s\n','$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
fprintf(fileID,'%s\n','$                             SECTION DEFINITIONS                              $');
fprintf(fileID,'%s\n','$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
for vLoop = 1:max(cLines(:,1))  
    thicknessTemp = mean(cLines(cLines(:,1)==vLoop,6));
    fprintf(fileID,'%s\n','*SECTION_SHELL');
    fprintf(fileID,'%10d%10d%10.4f%10.2f%10.1f%10.1f%10d\n',[vLoop meshControl.shellType 1 2 0 0 0]);
    fprintf(fileID,'%10.2f%10.2f%10.2f%10.2f%10.2f\n',[thicknessTemp thicknessTemp thicknessTemp thicknessTemp 0]);
end
fprintf(fileID,'%s\n%10d%10d\n','*SECTION_SOLID',1+max(cLines(:,1)),1); 

disp('          -> CREATING PART DATA')
fprintf(fileID,'%s\n','$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
fprintf(fileID,'%s\n','$                              PARTS DEFINITIONS                               $');
fprintf(fileID,'%s\n','$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
for tLoop = 1:max(cLines(:,1))
    fprintf(fileID,'%s\n','*PART');
    fprintf(fileID,'Part %8d for Mat %8d and Elem Type %8d\n',tLoop+3,1,1);
    fprintf(fileID,'%10d%10d%10d%10d%10d%10d%10d\n',[tLoop+3 tLoop 1 0 0 0 0]);
end
fprintf(fileID,'%s\n','*PART'); 
fprintf(fileID,'Part %8d for Mat %8d and Elem Type %8d\n',2,2,2);
fprintf(fileID,'%10d%10d%10d%10d%10d%10d%10d\n',[2 1+max(cLines(:,1)) 2 0 0 0 0]); 
fprintf(fileID,'%s\n','*PART'); 
fprintf(fileID,'Part %8d for Mat %8d and Elem Type %8d\n',3,2,2);
fprintf(fileID,'%10d%10d%10d%10d%10d%10d%10d\n',[3 1+max(cLines(:,1)) 2 0 0 0 0]); 
fclose(fileID);


% E.
disp('          -> CREATING LOAD DATA')
minY = min(cLines(:,3)-cLines(:,5)-cLines(:,6)/2);
maxY = max(cLines(:,3)+cLines(:,5)+cLines(:,6)/2);
uncompressedThickness = maxY-minY;
enforcedDisplacement = 0.5*(uncompressedThickness-physicsControl.targetThickness);

fileID = fopen(geometryInputFile,'at');
fprintf(fileID,'%s\n','*DEFINE_CURVE');
fprintf(fileID,'%10d%10d%10.3f%10.3f%10.3f%10.3f\n',[1 0 1 1 0 0]); 
fprintf(fileID,'%20.12E%20.12E\n',[0 0]);
fprintf(fileID,'%20.12E%20.12E\n',[physicsControl.solTime*0.7      -enforcedDisplacement+0.5*physicsControl.targetThickness]);
fprintf(fileID,'%20.12E%20.12E\n',[physicsControl.solTime*1.0      -enforcedDisplacement]);

fprintf(fileID,'%s\n','*DEFINE_CURVE');
fprintf(fileID,'%10d%10d%10.3f%10.3f%10.3f%10.3f\n',[2 0 1 1 0 0]); 
fprintf(fileID,'%20.12E%20.12E\n',[0 0]);
fprintf(fileID,'%20.12E%20.12E\n',[physicsControl.solTime*0.7      enforcedDisplacement-0.5*physicsControl.targetThickness]);
fprintf(fileID,'%20.12E%20.12E\n',[physicsControl.solTime*1.0      enforcedDisplacement]);

% F. 
fprintf(fileID,'%s\n','*BOUNDARY_PRESCRIBED_MOTION_RIGID');
fprintf(fileID,'%10d%10d%10d%10d%10.3f%10d%10.3f%10.3f\n',[2 2 2 1 1 0 0 0]); 
fprintf(fileID,'%s\n','*BOUNDARY_PRESCRIBED_MOTION_RIGID');
fprintf(fileID,'%10d%10d%10d%10d%10.3f%10d%10.3f%10.3f\n',[3 2 2 2 1 0 0 0]);  

% G.
disp('          -> CREATING SOLUTION SETTINGS DATA')
fprintf(fileID,'%s\n','*CONTACT_AUTOMATIC_GENERAL'); 
fprintf(fileID,'%10d%10d%10d%10d\n',[0 0 0 0]); 
fprintf(fileID,'%10.4f%10.4f%10.4f%10.4f%10.4f%10d%10.4f%10.4E\n',[1 1 0 0 0 0 0 0.1e21]); 
fprintf(fileID,'%10s\n',' ');
fprintf(fileID,'%s\n','*CONTROL_MPP_CONTACT_GROUPABLE'); 
fprintf(fileID,'%10d\n',3); 


% H.
fprintf(fileID,'%s\n','*CONTROL_TIMESTEP');
fprintf(fileID,'%10.4f%10.4f%10d%10.2f%10.2f\n',[0 0.7 0 0 0]);
% I.
fprintf(fileID,'%s\n','*CONTROL_TERMINATION');
fprintf(fileID,'%10.3E%10d%10.5f%10.5f%10.5f\n',[physicsControl.solTime*1.01 0 0 0 0]);
% J.
fprintf(fileID,'%s\n','*DATABASE_BINARY_D3THDT');
fprintf(fileID,'%10.4E\n',(physicsControl.solTime*1.01)/1000);


% Write nodes to track to file
fprintf(fileID,'%s\n','*DATABASE_HISTORY_NODE');
fprintf(fileID,'%10d%10d\n',min(solidNodalData(:,1)),max(solidNodalData(:,1)));
fprintf(fileID,'%s\n','*END');

fclose(fileID);

