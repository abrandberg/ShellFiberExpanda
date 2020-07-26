function partList = createPartStructure(nodesInModel,elementsInModel)

disp('-----> Generating part lists')
tic
Fibers = unique(elementsInModel(:,2));
Fibers(isnan(Fibers)) = [];
numFibers = length(Fibers);

for aLoop = 1:numFibers
    %disp(['Examining element connectivity of part ',num2str(aLoop)])
    partBeingChecked = Fibers(aLoop);
    partList(aLoop).partNumber = partBeingChecked;
    
    bolSel = elementsInModel(:,2)==partBeingChecked;
    partList(aLoop).elements = elementsInModel(bolSel,1);
    
    partList(aLoop).nodes = unique(elementsInModel(bolSel,3:6));
    partList(aLoop).nodalCoordinates = nodesInModel(ismember(nodesInModel(:,1),partList(aLoop).nodes),2:4);
    
    if numel(partList(aLoop).nodalCoordinates) == 0
        partList(aLoop).partNumber = nan;
    end
end

partList = partList(~isnan([partList.partNumber]));

toc



