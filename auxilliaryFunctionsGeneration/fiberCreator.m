function [startPos,lFiber,rFiber,tFiber,curvature] = fiberCreator(xDim,zDim,modeFlag,numericalFurnishArray)
%fiberCreator(xDim,zDim,modeFlag) creates a single fiber, either by sampling
%from some distribution or in singleFiber debug mode. the singleFiber mode
%is primarily intended to be used for debugging, mesh convergence studies, 
%and similar.
%
%INPUTS:		xDim		- 2x1 vector containing min and max x-coordinate.
%				zDim		- 2x1 vector containing min and max z-coordinate.
% 				modeFlag 	- Mode of sampling. Currently only supports random
%							  deposition and a debug mode for single fiber 
% 						      analysis. 
%
%OUTPUTS:		startPos 	- (X,Z) position of endpoint 1 of the fiber.
% 				lFiber 		- Fiber length.
% 				rFiber 		- Fiber radius.
% 				tFiber 		- Fiber wall thickness.
%               curvature   - Fiber curvature.
%
%REMARKS:
%
%
%
%created by: August Brandberg
%date: 09-04-2018
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xRange = range(xDim);
zRange = range(zDim);


switch modeFlag

    case 'singleFiber'
        startPos = [100 100];
        lFiber = 500;
        rFiber = 10;
        tFiber = 2;
        angXZ = 0;
        curvature = 0;
            
    case 'billerud'
        numRowsArray = size(numericalFurnishArray,1);
        
        rowSel = randi(numRowsArray);
        lFiber = numericalFurnishArray(rowSel,1);
        rFiber = numericalFurnishArray(rowSel,2);
        tFiber = numericalFurnishArray(rowSel,3);
        curvature =  numericalFurnishArray(rowSel,4);
        startPos = [randi(xRange),randi(zRange)]+[min(xDim),min(zDim)]; 
end
