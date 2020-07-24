function [outputArray] = csvTypeFurnish(fiberMode,furnishControl,ctrl)
disp('-> ENTERING NUMERICAL FURNISH MODULE')
formatString = '%10s %50s %10d\n';


switch fiberMode

    case 'billerud'
        CTMPunbeaten = importBillerudPulp(horzcat('numericalFurnish',ctrl.fileSep,'result_030419_1645.txt'));
        CTMPunbeaten(:,5) = (CTMPunbeaten(:,2)./CTMPunbeaten(:,1) - 1 )*100;
        formatString = '%10s %50s %10d\n';
        fprintf(formatString,'','Total number of fibers:',size(CTMPunbeaten,1))
        

        % Cleaning procedure:
        % 1. Remove nan values
        if furnishControl.removeNans == 1
            f1 = CTMPunbeaten(CTMPunbeaten(:,2)>0,:);   % Real length must be > 0
            f2 = f1(f1(:,3)>0,:);                       % Fiber width must be > 0
            fprintf(formatString,'','Removed due to NaN/0 entry:',size(CTMPunbeaten,1)-size(f2,1))
        end

        % 2. Remove wall thickness based on upper and lower bound
        f3 = f2(f2(:,4)>furnishControl.wallTknBoundLower,:);
        f4 = f3(f3(:,4)<furnishControl.wallTknBoundUpper,:);
        fprintf(formatString,'','Removed due to lower bound on wall thickness:',size(f2,1)-size(f3,1))
        fprintf(formatString,'','Removed due to upper bound on wall thickness:',size(f3,1)-size(f4,1))

        % 3. Remove width based on upper and lower bound
        f5 = f4(f4(:,3)>furnishControl.diameterBoundLower,:);
        f6 = f5(f5(:,3)<furnishControl.diameterBoundUpper,:);
        fprintf(formatString,'','Removed due to lower bound on diameter:',size(f4,1)-size(f5,1))
        fprintf(formatString,'','Removed due to upper bound on diameter:',size(f5,1)-size(f6,1))

        % 4. Remove based on curl
        f7 = f6(f6(:,5)>furnishControl.curlBoundLower,:);
        f8 = f7(f7(:,5)<furnishControl.curlBoundUpper,:);

        fprintf(formatString,'','Removed due to too little curl:',size(f6,1)-size(f7,1))
        fprintf(formatString,'','Removed due to too much curl:',size(f7,1)-size(f8,1))

        CTMPunbeatenCleaned = f8;

        outputArray = [CTMPunbeatenCleaned(:,2).*1e3 ...                         % Projected length
                       CTMPunbeatenCleaned(:,3)./2   ...                         % Equivalent radius (same as width in this case)
                       CTMPunbeatenCleaned(:,4)      ...                         % Wall thickness
                       CTMPunbeatenCleaned(:,5)./100];                           % Curl

        % Apply correction factors for wet vs dry state
        outputArray(:,2) = outputArray(:,2).*furnishControl.swellingFactorDiameter;
        outputArray(:,3) = outputArray(:,3).*furnishControl.swellingFactorWallTkn;

        fprintf(formatString,'','Final tally of eligible fibers:',size(outputArray,1))

end

