function divLength = elementLengthOptimization(rFiber,meshControl)

% Maximum length to avoid numerical instability
divLength = meshControl.aspectRatio*2*pi*rFiber/meshControl.aDiv; 
