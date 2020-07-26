function writeContactCard(elementsInModel,partList,outputFileName)

% 3(a) Find the number of parts to be created
Fibers = unique(elementsInModel(:,2));
Fibers(isnan(Fibers)) = [];
numFibers = length(Fibers);

fileID = fopen(outputFileName,'w');
for xLoop = 1:numel(partList)
    
    fiberAnalyzed = Fibers(xLoop);

    % Check that there is at least one contact
    if numel(partList(xLoop).contactList) > 0
        
        % Write a *SET_PART list that can be appended
        fprintf(fileID,'%s\n','*SET_PART_LIST');
        fprintf(fileID,'%s\n','$#     sid       da1       da2       da3       da4    solver      ');
        fprintf(fileID,'%10d%s\n',5000+xLoop,'       0.0       0.0       0.0       0.0MECH');

        lastRowValues = mod(numel(partList(xLoop).contactList),7);
        fprintf(fileID,'%10d%10d%10d%10d%10d%10d%10d\n',partList(xLoop).contactList);
        if lastRowValues > 0
            fprintf(fileID,'\n');
        end

        fprintf(fileID,'%s\n','*CONTACT_AUTOMATIC_SURFACE_TO_SURFACE_TIEBREAK_ID');
        fprintf(fileID,'%s\n','$#     cid                                                                 title');
        fprintf(fileID,'%10d\n',xLoop);
        fprintf(fileID,'%s\n','$#    ssid      msid     sstyp     mstyp    sboxid    mboxid       spr       mpr');
        fprintf(fileID,'%10d%10d%s\n',fiberAnalyzed,5000+xLoop,'         3         2         0         0         2         2'); % 5 och 3
        fprintf(fileID,'%s\n','$#      fs        fd        dc        vc       vdc    penchk        bt        dt');
        fprintf(fileID,'%s\n','       0.0       0.0       0.0       0.0       0.0         0       0.01.00000E20');
        fprintf(fileID,'%s\n','$#     sfs       sfm       sst       mst      sfst      sfmt       fsf       vsf');
        fprintf(fileID,'%s\n','       0.1       0.1       0.0       0.0       1.0       1.0       1.0       1.0');
        fprintf(fileID,'%s\n','$#  option      nfls      sfls     param    eraten    erates     ct2cn        cn');
        fprintf(fileID,'%s\n','         2    1000.0     500.0       0.0       0.0       0.0       0.0       0.0');
        fprintf(fileID,'%s\n','$#    soft    sofscl    lcidab    maxpar     sbopt     depth     bsort    frcfrq');
        fprintf(fileID,'%s\n','         0');
    end
    
end
    
fclose(fileID);
