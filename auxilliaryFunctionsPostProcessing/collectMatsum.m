function outputMATSUM = collectMatsum(fileName)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next file: 
% MATSUM file
%
% Three things to track here:
% MATERIAL NUMBER
% TIME STEP
% 13 SCALAR VALUES DESCRIBING THE PART STATE
%
%
% One way to handle it is to do it "the excel way":
% Keep the array flat by writing time and MAT on each row, followed by the scalars.
% Then some filtering will be necessary.
%
% Another way is of course to use 3D indexing:
%
% OUTPUT(MAT, 13 SCALAR VALUES , TIME STEP)
%
% The columns to be mapped are:
% 1  time-step
% 2  material
% 3  internal energy
% 4  kinetic energy
% 5  eroded internal energy
% 6  eroded kinetic energy
% 7  x-momentum
% 8  y-momentum
% 9  z-momentum
% 10 x-rbv (rbv = rigid body velocity maybe????) 
% 11 y-rbv
% 12 z-rbv
% 13 hgeng (hourglass energy)


outputMATSUM = nan(1000,13,1000);
timeIdx = 0;

fid = fopen(fileName); % Open the file
tline = fgetl(fid);

while ischar(tline)
    tline = fgetl(fid);
%       disp(tline)             % Show the line that is about to be examined
          
      if length(tline) > 6

        % Time index should be altered when the string 'time = ' is displayed
        if strcmp(tline(1:7),' time =')
            timeIdx = timeIdx + 1;
            currTime = str2double(tline(8:20));

        % Mat index should be altered when the string ' mat.#=' is displayed
        elseif strcmp(tline(1:7),' mat.#=')
            matIdx = str2double(tline(8:13));
            outputMATSUM(matIdx,1,timeIdx) = currTime; 
            outputMATSUM(matIdx,2,timeIdx) = matIdx; 
            outputMATSUM(matIdx,3,timeIdx) = str2double(tline(32:44));      % Internal energy
            outputMATSUM(matIdx,4,timeIdx) = str2double(tline(56:68));      % Kinetic energy
            outputMATSUM(matIdx,5,timeIdx) = str2double(tline(84:96));      % Eroded internal energy
            outputMATSUM(matIdx,6,timeIdx) = str2double(tline(112:124));    % Eroded kinetic energy

            tline = fgetl(fid);
            outputMATSUM(matIdx,7,timeIdx) = str2double(tline(8:20));       % x-momentum
            outputMATSUM(matIdx,8,timeIdx) = str2double(tline(32:44));      % y-momentum
            outputMATSUM(matIdx,9,timeIdx) = str2double(tline(56:68));      % z-momentum

            tline = fgetl(fid); 
            outputMATSUM(matIdx,10,timeIdx) = str2double(tline(8:20));       % x-rbv (rbv = rigid body velocity maybe????)
            outputMATSUM(matIdx,11,timeIdx) = str2double(tline(32:44));      % y-rbv (rbv = rigid body velocity maybe????)
            outputMATSUM(matIdx,12,timeIdx) = str2double(tline(56:68));      % z-rbv (rbv = rigid body velocity maybe????)  

            tline = fgetl(fid);
            outputMATSUM(matIdx,13,timeIdx) = str2double(tline(32:44));      % hgeng (hourglass energy)     
        end      
      end
end

fclose(fid);   
outputMATSUM(isnan(outputMATSUM(:,1,1)),:,:) = [];
outputMATSUM(:,:,isnan(outputMATSUM(1,1,:))) = [];

% 
% 
% figure; 
% 
% for aaLoop = 1:size(outputMATSUM,3)
%     zzp = squeeze(outputMATSUM(:,:,aaLoop));
%     
% %     subplot(3,3,1)
%     
%     
%     subplot(3,4,1)
%     scatter(zzp(:,2),zzp(:,3),'.b')
%     title('internal energy per part')
% %     hold on
%     
%     subplot(3,4,2)
%     scatter(zzp(3:end,2),zzp(3:end,4),'.b')
% %     hold on
%     title('Kinetic Energy per part')
% 
%     subplot(3,4,3)
%     scatter(zzp(:,2),zzp(:,5),'.b')
% %     hold on
%     title('eroded internal energy')
%     
%     subplot(3,4,4)
%     scatter(zzp(3:end,2),zzp(3:end,6),'.b')
% %     hold on
%     title('eroded kinetic energy')
%     
%     subplot(3,4,5)
%     scatter(zzp(3:end,2),zzp(3:end,7),'.b')
% %     hold on
%     title('x-momentum')
%     
%     subplot(3,4,6)
%     scatter(zzp(3:end,2),zzp(3:end,8),'.b')
% %     hold on
%     title('y-momentum')
%     
%     subplot(3,4,7)
%     scatter(zzp(3:end,2),zzp(3:end,9),'.b')
% %     hold on
%     title('z-momentum')
%     
%     subplot(3,4,8)
%     scatter(zzp(3:end,2),zzp(3:end,10),'.b')
% %     hold on
%     title('x-rbv')
%     
%     
%     subplot(3,4,9)
%     scatter(zzp(3:end,2),zzp(3:end,11),'.b')
% %     hold on
%     title('y-rbv')
%  
%     subplot(3,4,10)
%     scatter(zzp(3:end,2),zzp(3:end,12),'.b')
% %     hold on
%     title('z-rbv')
%     
%     subplot(3,4,11)
%     scatter(zzp(3:end,2),zzp(3:end,13),'.b')
% %     hold on
%     title('hgeng')
%     
%     
%     subplot(3,4,12)
%     title(['Timestep ' num2str(aaLoop) ' / ' num2str(size(outputMATSUM,3))])
% 
%     
%     pause(0.2)
% 
% end
