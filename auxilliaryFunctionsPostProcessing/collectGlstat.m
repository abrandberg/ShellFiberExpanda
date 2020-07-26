function outputGLSTAT = collectGlstat(fileName)






% 19 rows
% Add in rows for:
%    (1)    Cycle
%    (2)    controlling shell
%    (3)    controlling part
%    (4)    time
%    (5)    timestep
%    (6)    kinetic energy
%    (7)    internal energy
%    (8)    spring and damper energy
%    (9)    hourglass energy
%    (10)   system damping energy
%    (11)   sliding interface energy
%    (12)   external work
%    (13)   eroded kinetic energy
%    (14)   eroded internal energy
%    (15)   eroded hourglass energy
%    (16)   total energy
%    (17)   total energy / initial energy
%    (18)   energy ratio w/o eroded energy
%    (19)   global x velocity
%    (20)   global y velocity
%    (21)   global z velocity
%    (22)   time per zone cycle.(nanosec)

outputGLSTAT = nan(1000,22);


fid = fopen(fileName); % Open the file

tline = fgetl(fid);

writeRow = 0;

while ischar(tline)
    tline = fgetl(fid);
%      disp(tline)             % Show the line that is about to be examined
    
    if length(tline) > 31
        if strcmp(tline(1:12),' dt of cycle')
            writeRow = writeRow + 1;
            outputGLSTAT(writeRow,1) = str2double(tline(14:20)); % cycle
            outputGLSTAT(writeRow,2) = str2double(tline(45:53)); % controlling element
            outputGLSTAT(writeRow,3) = str2double(tline(63:71)); % controlling part
        else
            switch tline(1:32)           
            case ' time...........................'
                outputGLSTAT(writeRow,4) = str2double(tline(35:46));
            case ' time step......................'
                outputGLSTAT(writeRow,5) = str2double(tline(35:46));
            case ' kinetic energy.................'
                outputGLSTAT(writeRow,6) = str2double(tline(35:46));
            case ' internal energy................'
                outputGLSTAT(writeRow,7) = str2double(tline(35:46));
            case ' spring and damper energy.......'
                outputGLSTAT(writeRow,8) = str2double(tline(35:46));
            case ' hourglass energy ..............'
                outputGLSTAT(writeRow,9) = str2double(tline(35:46));
            case ' system damping energy..........'
                outputGLSTAT(writeRow,10) = str2double(tline(35:46));
            case ' sliding interface energy.......'
                outputGLSTAT(writeRow,11) = str2double(tline(35:46));
            case ' external work..................'
                outputGLSTAT(writeRow,12) = str2double(tline(35:46));
            case ' eroded kinetic energy..........'
                outputGLSTAT(writeRow,13) = str2double(tline(35:46));
            case ' eroded internal energy.........'
                outputGLSTAT(writeRow,14) = str2double(tline(35:46));
            case ' eroded hourglass energy........'
                outputGLSTAT(writeRow,15) = str2double(tline(35:46));
            case ' total energy...................'
                outputGLSTAT(writeRow,16) = str2double(tline(35:46));
            case ' total energy / initial energy..'
                outputGLSTAT(writeRow,17) = str2double(tline(35:46));
            case ' energy ratio w/o eroded energy.'
                outputGLSTAT(writeRow,18) = str2double(tline(35:46));
            case ' global x velocity..............'
                outputGLSTAT(writeRow,19) = str2double(tline(35:46));
            case ' global y velocity..............'
                outputGLSTAT(writeRow,20) = str2double(tline(35:46));
            case ' global z velocity..............'
                outputGLSTAT(writeRow,21) = str2double(tline(35:46));
            case ' time per zone cycle.(nanosec)..'
                outputGLSTAT(writeRow,22) = str2double(tline(35:46));
                    
            end
            
        end
    end
end

% Close file
fclose(fid);   
outputGLSTAT(isnan(outputGLSTAT(:,1)),:) = [];