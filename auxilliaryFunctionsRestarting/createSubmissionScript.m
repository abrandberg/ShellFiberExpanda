function createSubmissionScript(exeInformation)
%function createSubmissionScript(exeInformation) creates a .SH file
% which can be used to submit the input files to a PBS job scheduler.
% For now, the available options are all highly specific to my current
% employer, KTH Engineering Mechanics.
%
% If you have your own linux cluster you wish to submit jobs to, I suggest
% you adapt the function to your own needs.
%
% INPUTS:   exeInformation      Described in networkGenerator.m
%
% OUTPUTS:  A .SH file which can be used to submit jobs to PBS.
%
% created by: August Brandberg
% date: 2020-07-24

switch exeInformation.exeEnvironment
    
    case 'tensor'        
        % Hardcoded for now
        exeInformation.executable     = '/usr/lsdyna/ls-dyna_mpp_d_r101';
        
        executionString = horzcat('mpirun -np ', num2str(exeInformation.np),    ...
                                  ' ',exeInformation.executable,       ...
                                  ' NCPU=',num2str(exeInformation.np),           ...
                                  ' i=' ,exeInformation.mainCardFile, ...
                                  ' > '  ,exeInformation.outputFile);
        fileID = fopen(exeInformation.exeFileName,'w');
        fprintf(fileID,'%s\n','#!/bin/bash');
        fprintf(fileID,'%s\n','#PBS -z');
        fprintf(fileID,'%s\n','#PBS -V');
        fprintf(fileID,'%s\n',horzcat('#PBS -l nodes=1:ppn=',num2str(exeInformation.np)));
        fprintf(fileID,'%s\n','cd $PBS_O_WORKDIR');
        fprintf(fileID,'%s\n',executionString);
        fclose(fileID);
        
    case 'bertil'     
        % Hardcoded for now
        exeInformation.executable     = 'ls-dyna_mpp_d_r110';
        
        executionString = horzcat('mpirun -np ', num2str(exeInformation.np),    ...
                                  ' ',exeInformation.executable,       ...
                                  ' memory=300000000',          ...
                                  ' i=' ,exeInformation.mainCardFile, ...
                                  ' > '  ,exeInformation.outputFile);
        fileID = fopen(exeInformation.exeFileName,'w');
        fprintf(fileID,'%s\n','#!/bin/bash');
        fprintf(fileID,'%s\n','#PBS -z');
        fprintf(fileID,'%s\n','#PBS -V');
        fprintf(fileID,'%s\n',horzcat('#PBS -l nodes=1:ppn=',num2str(exeInformation.np)));
        fprintf(fileID,'%s\n','cd $PBS_O_WORKDIR');
        fprintf(fileID,'%s\n',executionString);
        fclose(fileID);
    
    case 'burster'
        exeInformation.executable     = '/usr/LS-Dyna/ls-dyna_smp_d_r110';
        
        executionString = horzcat(exeInformation.executable,       ...
                                  ' NCPU=',num2str(exeInformation.np),           ...
                                  ' i=' ,exeInformation.mainCardFile, ...
                                  ' > '  ,exeInformation.outputFile);
        fileID = fopen(exeInformation.exeFileName,'w');
        fprintf(fileID,'%s\n','#!/bin/bash');
        fprintf(fileID,'%s\n','#PBS -z');
        fprintf(fileID,'%s\n','#PBS -V');
        fprintf(fileID,'%s\n',horzcat('#PBS -l nodes=1:ppn=',num2str(exeInformation.np)));
        fprintf(fileID,'%s\n','cd $PBS_O_WORKDIR');
        fprintf(fileID,'%s\n',executionString);
        fclose(fileID);
        
    case 'kebnekaise'
        exeInformation.executable     = '/pfs/nobackup/home/a/augustbr/lsdyna/ls-dyna_mpp_d_r10_1_f';
        
        executionString = horzcat('srun ',exeInformation.executable,       ...
                                  ' NCPU=',num2str(exeInformation.np),           ...
                                  ' memory=500000000 memory2=50000000',...
                                  ' i=' ,exeInformation.mainCardFile, ...
                                  ' > '  ,exeInformation.outputFile);
        fileID = fopen(exeInformation.exeFileName,'w');
        fprintf(fileID,'%s\n','#!/bin/bash');
        fprintf(fileID,'%s\n','#SBATCH -A SNIC2018-3-212');
        fprintf(fileID,'%s\n',horzcat('#SBATCH -N ',num2str(ceil(exeInformation.np/28))));
        fprintf(fileID,'%s\n',horzcat('#SBATCH -n ',num2str(exeInformation.np)));
        fprintf(fileID,'%s\n',horzcat('#SBATCH --time=',exeInformation.exeTime));
        fprintf(fileID,'%s\n',executionString);
        fclose(fileID);        
        
end