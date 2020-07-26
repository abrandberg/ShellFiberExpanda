function boundaryConditionsRestart_v2(boundaryControl,physicsControl,fileName)
% We will use a single file to store all of the boundary conditions. The
% boundary conditions have the following basic check list:
% 
% INPUTS: 1. A set of nodes onto which the boundary conditions are to be
%            applied.
%         2. An axis along which the boundary condition is to be applied.
%         3. A flag for the type of boundary condition to be applied
%           (displacement, velocity or acceleration to begin with).
%         4. The end time of the simulation.
%         5. The inline function which should be used to form the curve.
%         6. The number of points which should be used to form the curve.
%         7. A file onto which the results should be appended.

% The steps inside the function is as follows:
%         1. Construct *SET_NODE_LIST
%         2. Construct *DEFINE_CURVE
%         3. Construct *BOUNDARY_PRESCRIBED_MOTION_SET
% 
% created by: August Brandberg
% date: 2020-07-25
%

fileID = fopen(fileName.boundaryFile,'a');
for zLoop = 1:numel(boundaryControl)

    fprintf(fileID,'%s\n','*SET_NODE_LIST');
    fprintf(fileID,'%s\n','$#     sid       da1       da2       da3       da4    solver      ');
    fprintf(fileID,'%s\n',horzcat('     ',num2str(10000+zLoop),'       0.0       0.0       0.0       0.0MECH'));
    writeNodes(boundaryControl(zLoop).nodeSet,fileID);

    for DOFLoop = 1:numel(boundaryControl(zLoop).loadAxis)           
        [tTemp,cTemp] = discretizeCurves([0 physicsControl.solTime],boundaryControl(zLoop).fcnCurve,boundaryControl(zLoop).fcnDisc);
        fprintf(fileID,'%s\n','*DEFINE_CURVE ');
        fprintf(fileID,'%10d%10d%10.3f%10.3f%10.3f%10.3f\n',eval(horzcat('5',num2str(zLoop),num2str(DOFLoop))),0,1,1,0,0);%'        22         0     1.000     1.000     0.000     0.000 ');
        for xLoop = 1:size(cTemp,2)
            fprintf(fileID,'%20.12E%20.12E\n',tTemp(xLoop),cTemp(xLoop));
        end

        fprintf(fileID,'%s\n','*BOUNDARY_PRESCRIBED_MOTION_SET');
        fprintf(fileID,'%s\n','$#  typeid       dof       vad      lcid        sf       vid     death     birth');
        fprintf(fileID,'%10d%10d%10d%10d%s\n',10000+zLoop,boundaryControl(zLoop).loadAxis(DOFLoop),boundaryControl(zLoop).loadType(DOFLoop),eval(horzcat('5',num2str(zLoop),num2str(DOFLoop))),'       1.0         01.00000E28');
    end
end

fprintf(fileID,'%s\n','*CONTROL_TERMINATION');
fprintf(fileID,'%10.3E %s\n',physicsControl.solTime,'         0   0.00000   0.00000   0.00000 ');
fclose(fileID);

end

function writeNodes(nodesInSet,fileID)
for yLoop = 1:length(nodesInSet)
    if mod(yLoop,8)==0 || yLoop == length(nodesInSet)
        fprintf(fileID,'%10s\n',num2str(nodesInSet(yLoop)));
    else
        fprintf(fileID,'%10s',num2str(nodesInSet(yLoop)));
    end
end
end

function [tTemp,cTemp] = discretizeCurves(time,fcnToDiscretize,fcnDisc)
    tTemp = linspace(time(1),time(2),fcnDisc);
    cTemp = fcnToDiscretize(tTemp); 
    if length(cTemp) == 1
        cTemp = cTemp*ones(size(tTemp));
    end
end

