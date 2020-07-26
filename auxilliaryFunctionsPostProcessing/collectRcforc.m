function outputRCFORC = collectRcforc(fileName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RCFORC export
%
% This is a tricky one for several reasons. First, it is very big. Second, it contains
% variable data, and master/slave lines. Third, it needs to be carefully assessed to be
% able to get some info out, because the contact sets are defined for maximum convenience,
% not maximum interpretability of the result.
%
% Here we are going to structure the output slightly different, in two structs.
% One struct will contain the master side, the other the slave side.
%
%



tOld = 0;
timeIdx = 1;
outputRCFORC = nan(10000,11,1000);



fid = fopen(fileName); % Open the file
tline = fgetl(fid);
while ischar(tline)
    tline = fgetl(fid);
%       disp(tline)             % Show the line that is about to be examined
          
      if length(tline) > 50
         if strcmp(tline(1:8),'  slave ') 
             % Start inputting the data. The data to be recorded is, 
             % Master or slave (slave only currently)
             % time
             % Fx
             % Fy
             % Fz
             % Mass (?????)
             % Moment_x
             % Moment_y
             % Moment_z
             % Tied elements (????????)
             % Tied area (presumably in um^2 then)
             % The structure is a MxNxP structure again
             
                         
             currCont = str2double(tline(9:19));
             currTime = str2double(tline(25:36));
             
             if currTime ~= tOld
                % Increment time index
                timeIdx = timeIdx + 1;
                tOld = currTime;
             end
             
             outputRCFORC(currCont,1,timeIdx) = currTime;                        % time
             outputRCFORC(currCont,2,timeIdx) = currCont;                        % Current contact set
             outputRCFORC(currCont,3,timeIdx) = str2double(tline(40:52));        % Fx
             outputRCFORC(currCont,4,timeIdx) = str2double(tline(56:68));        % Fy
             outputRCFORC(currCont,5,timeIdx) = str2double(tline(72:84));        % Fy
             outputRCFORC(currCont,6,timeIdx) = str2double(tline(90:102));       % Mass
             outputRCFORC(currCont,7,timeIdx) = str2double(tline(107:119));      % Mx
             outputRCFORC(currCont,8,timeIdx) = str2double(tline(124:136));      % My
             outputRCFORC(currCont,9,timeIdx) = str2double(tline(141:153));      % Mz
             
             if length(tline) > 158
                 outputRCFORC(currCont,10,timeIdx) = str2double(tline(160:170)); % Tied elements
                 outputRCFORC(currCont,11,timeIdx) = str2double(tline(182:194)); % Tied area
                 
             else
                 outputRCFORC(currCont,10,timeIdx) = 0; % Tied elements
                 outputRCFORC(currCont,11,timeIdx) = 0; % Tied area                 
             end
         end       
      end
end

fclose(fid);   
outputRCFORC(isnan(outputRCFORC(:,1,1)),:,:) = [];
outputRCFORC(:,:,isnan(outputRCFORC(1,1,:))) = [];

% figure;
% for aaLoop = 1:size(outputRCFORC,3)
%     zzp = squeeze(outputRCFORC(:,:,aaLoop));
%     
%     plot(zzp(:,2),sqrt(zzp(:,3).^2+zzp(:,4).^2+zzp(:,5).^2),'.b')
%     pause(0.2)
% 
% end