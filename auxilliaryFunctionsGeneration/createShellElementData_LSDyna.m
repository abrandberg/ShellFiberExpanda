function [shellElementData] = createShellElementData_LSDyna(cLines,meshControl)

%*ELEMENT_SHELL 
%     IDX    PART    NODE    NODE    NODE    NODE
%       1       4       1       2       3       4 

shellElementData = zeros((size(cLines,1)-max(cLines(:,1)))*meshControl.aDiv,6);
counter = 1;
nodeOffset = 0;
kcdel = meshControl.aDiv;

for zLoop = 1:max(cLines(:,1))
    tic
    % For each fiber in the set
    kldel = sum(cLines(:,1)==zLoop); %counts how many segments in a fiber

    
    for ii=0:kldel-2 % Minus 1 because last row doesn't need its own iteration, minus another 1 because starting from row 0!
       for i=1:kcdel
           if i<kcdel % Standard form
               
               %  |------------------> z
               %
               %  phi 
               %  ^      jkp +--------------+ kkp
               %  |          |              |
               %  |          |              |
               %  -      ikp +--------------+ lkp
               %
                % FIRST SET ALONG LENGTH: 
                % First nodes should come from the last ones in the last
                % circle:
                %           IKP JKP KKP LKP
                % Round 1:    1   2  12  11     -> OK
                % Round 2:    2   3  13  12     -> OK
                % Final set: 10   1  11  20     -> OK
                
                % SECOND SET ALONG LENGTH: 
                % First nodes should come from the last ones in the last
                % circle:
                %           IKP JKP KKP LKP
                % Round 1:   11  12  22  21     -> OK
                % Round 2:   12  13  23  22     -> OK
                % Final set: 20  11  31  30     -> OK               
        		ikp = nodeOffset+kcdel*ii+i;
        		jkp = nodeOffset+kcdel*ii+i+1;
        		kkp = nodeOffset+kcdel*(ii+1)+i+1;
        		lkp = nodeOffset+kcdel*(ii+1)+i;        

                if i==1
                   ikpSave = ikp;
                   lkpSave = lkp;
                end
           else % This only happens in the last set, where we need to connect back to the first nodes in the set.
                % That means that 2 of the nodes (ikp and jkp) should
                % actually be the first nodes in the set. How do we find
                % them? The easiest way is to record them
        		ikp = nodeOffset+kcdel*ii+i;
        		jkp = ikpSave;
        		kkp = lkpSave;
        		lkp = nodeOffset+kcdel*(ii+1)+i;        
           end
           
           % Aggregate the information.
           shellElementData(counter,:) = [counter zLoop+3 ikp jkp kkp lkp];
           counter = counter + 1; 
           
%            if modeFlag == 1
%                patch('XData',nodalData([ikp jkp kkp lkp],2),...
%                      'YData',nodalData([ikp jkp kkp lkp],3),...
%                      'ZData',nodalData([ikp jkp kkp lkp],4),...
%                      'FaceColor','red')%,'FaceAlpha',0.3
%                view([0 -70])
%                hold on
%                axis equal
%                title(horzcat('Working on fiber ',num2str(zLoop)))
%                pause(0.05)
%            end
       end
        
    end
    nodeOffset = max([ikp jkp kkp lkp]);
    tTemp(zLoop) = toc;
end
% figure();
% plot(1:zLoop,tTemp,'-o')
% xlabel('Fiber')
% ylabel('Time to deposit [s]')



