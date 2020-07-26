function cNodeData = importNodesFast(nFile)

 
% tic
fileID = fopen(nFile);
filemod = textscan(fileID,'%s','delimiter','\n','whitespace', '');
fclose(fileID);

        filemod = filemod{1,1};

        filemod(1:5) = [];
        filemod(end) = [];       

        writeKFileFast(filemod,'outTest.txt')

        cNodeData=dlmread('outTest.txt');
%         cNodeData = reshape(cNodeData',[],4);
%         fid = fopen('outTest.txt');
%         cNodeData = textscan(fid,'%8.f %14f %14f %14f\n');
%         fclose(fid);
%         toc
        
        
        
%         
%           eCollect(zLoop,1) = str2double(tline(1:8));
%             eCollect(zLoop,2) = str2double(tline(9:24));
%             eCollect(zLoop,3) = str2double(tline(25:40));
%             eCollect(zLoop,4) = str2double(tline(41:56));