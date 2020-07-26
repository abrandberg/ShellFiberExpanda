function C = replaceLSDYNA(originalFile,changeStructure)
%replaceLSDYNA(originalFile,changeStructure) goes through a file of string,
%looking at each line and comparing it with each entry in a structure
%containing pre-specified changes the user wishes to make to the file. This
%can be convenient when a .K file has been generated for LS-Dyna, and some
%parts of that file need to be adjusted in preparation of e.g. a restart
%procedure. 
%
% INPUTS:
%           originalFile    -   Cell array containing the text file to be
%                               searched.
%           changeStructure -   Structure containing all of the information
%                               regarding what to look for and what changes
%                               to make.
%
% OUTPUTS: 
%           C               -   The updated cell aray, with the changes.
% 
% TO DO:
%  - This code could be made to work significantly faster, if that is
%    interesting (30-11-2018).
%
% created by: August Brandberg
% date: 30-11-2018
%
% Information about changeStructure:
% Change structure has the following fields:
%   - CriterionCurrent
%           String to look for at the current line.
%   - CriterionPrevious
%           String on the line above the line to be changed.
%   - CriterionNext
%           String on the line after the line to be changed.
%   - InstructionType
%           Type of change to make. Possible choices are:
%               ADD
%               REPLACE
%               DELETE
%   - Instruction
%           Here the specific change can be specified. For example, if a
%           line is to be replaced by another line, the "another line" is
%           specified as a cell here.
%   - DeleteLines
%           Number of rows to skip. This is convenient because typically
%           you match on the *KEYWORD line and then that keyword contains a
%           number of lines before the next keyword. Here you can (if you
%           know the number of lines that will need to be deleted) specify
%           that directly, instead of performing a separate search. 
%
%   AT LEAST ONE CHANGESTRUCTURE ENTRY NEEDS TO CONTAIN ALL OF
%   CRITERIONPREVIOUS, CRITERIONCURRENT AND CRITERIONNEXT. HOWEVER, THE
%   SUPPLIED VALUE CAN BE A NULL VALUE.
%
% Example:
% changeStructure(1).CriterionCurrent  = '';
% changeStructure(1).CriterionPrevious = '*CONTROL_TERMINATION';
% changeStructure(1).CriterionNext     = '';
% changeStructure(1).InstructionType   = 'replace';
% changeStructure(1).Instruction       = {horzcat(tempTimeStr,'         0   0.00000   0.00000')};
% changeStructure(1).DeleteLines       = 1;
%

% Initialize
readLine = '';
mLoop = 1;
C = [];

foundAndEdited = zeros(numel(changeStructure),1);

% Fill out the values that were not supplied.
for kLoop = 1:numel(changeStructure)
    changeStructure(kLoop).pastEmpty = isempty(changeStructure(kLoop).CriterionPrevious);
    changeStructure(kLoop).currentEmpty = isempty(changeStructure(kLoop).CriterionCurrent);
    changeStructure(kLoop).nextEmpty = isempty(changeStructure(kLoop).CriterionNext);
end



while mLoop <= size(originalFile,1)
    
    readLineOld = readLine;
    readLine = originalFile{mLoop};
    
    if mLoop < size(originalFile,1)
            readLineNext = originalFile{mLoop+1};
    else 
            readLineNext = '';
    end
    
    editFlag = 0;
    
    for oLoop = 1:length(changeStructure)
        % Check if a CriterionPrevious was passed
        if changeStructure(oLoop).pastEmpty %isempty(changeStructure(oLoop).CriterionPrevious)
            pastFlag = 1;
        else 
            pastFlag = contains(readLineOld,changeStructure(oLoop).CriterionPrevious);
        end
        
        % Check if a CriterionCurrent was passed
        if changeStructure(oLoop).currentEmpty %isempty(changeStructure(oLoop).CriterionCurrent)
            currentFlag = 1;
        else 
            currentFlag = contains(readLine,changeStructure(oLoop).CriterionCurrent);
        end   
        
        % Check if a CriterionNext was passed
        if isfield(changeStructure,'CriterionNext') && changeStructure(oLoop).nextEmpty %isempty(changeStructure(oLoop).CriterionNext)
            nextFlag = 1;
        elseif isfield(changeStructure,'CriterionNext') 
            nextFlag = contains(readLineNext,changeStructure(oLoop).CriterionNext);
        else
            nextFlag = 1;
        end   
        
        % Single loop for trial

        if pastFlag && currentFlag && nextFlag

            if strcmp(changeStructure(oLoop).InstructionType,'add')  % Tested and functional
                % Supports adding multi-line
                C{end+1,1} = readLine;

                for nLoop = 1:length(changeStructure(oLoop).Instruction)
                    C{end+1,1} = changeStructure(oLoop).Instruction{1,nLoop};
                end
                
                
                mLoop = mLoop + changeStructure(oLoop).DeleteLines; 
                editFlag = 1;

            elseif strcmp(changeStructure(oLoop).InstructionType,'replace') % Tested and functional
                % Supports replacing single line with multi-line

                for nLoop = 1:length(changeStructure(oLoop).Instruction)
                    C{end+1,1} = changeStructure(oLoop).Instruction{1,nLoop};
                end
                
                mLoop = mLoop + changeStructure(oLoop).DeleteLines;      
                editFlag = 1;

            elseif strcmp(changeStructure(oLoop).InstructionType,'delete') % Tested and functional

                mLoop = mLoop + changeStructure(oLoop).DeleteLines;
                editFlag = 1;
                
            end
            foundAndEdited(oLoop) = 1+foundAndEdited(oLoop);
        else
            if oLoop == length(changeStructure) && editFlag == 0 % If on the last submitted criterion, increment
                C{end+1,1} = readLine;
                mLoop = mLoop + 1; 
            end

        end
    end
end

% strFormat = '%10.1d';
% fprintf('%s\n','Criteria Found:')
% fprintf('%10.1d\n')
% foundAndEdited'






