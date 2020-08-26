# ShellFiberExpanda
Accompanying code to C. Ceccato, A. Brandberg, C. Barbier, A. Kulachenko, 202X


## Installation
This code was written from the comfort of a well funded university office. For this reason, little concern was given to whether the code would be portable. Sorry about that.

You will need the following to run everything in this repository:

    MATLAB (Developed and tested on 2017b)

    LS-PrePost (Developed and tested on 4.7.0)
    https://www.lstc.com/products/ls-prepost

    LS-Dyna (Developed and tested on MPP R11.0.0 revision 129956)

    GRAMM - A toolbox for visualization in MATLAB
    [1] P. Morel, “Gramm: grammar of graphics plotting in Matlab,” J. Open Source Softw., vol. 3, no. 23, p. 568, Mar. 2018, doi: 10.21105/joss.00568.

    An edited version of the Curve intersections file from MATLAB Central
    NS (2020). Curve intersections (https://www.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections), MATLAB Central File Exchange. Retrieved July 23, 2020.

    Edit the function interX.m so that the first line of the function reads:
    [P,i,j] = InterXmod(L1,varargin) instead of
    P = InterX(L1,varargin)
    and save the function as "InterXmod.m"

To generate networks and look at them, you don't need more than a laptop. However, if you try to perform LS-Dyna solves on something smaller than a workstation, **you will have a bad time.**

## Who is this repository for?
- My advisor
- The reviewers of the forthcoming article, if they wish to look at the specific implementation I have chosen.
- Anyone who intends to write a code to simulate fiber networks, who wants to "compare notes".

## Why did you do this like this?
- The code was originally intended as a proof of concept, and then mission-creep eventually caused it to be much bigger than that.
- I am a mechanical engineer working on solid mechanics problems. This has steered my programming style [sic] and what is/is not explained in detail.



## Trouble-shooting
Let me know and maybe I can help you.

## Analysis flow

1. Open *networkGeneration.m* in MATLAB and make sure the settings match your expectations.

2. Run *networkGeneration.m*. If all goes well, a directory will be generated which contains the inputs to LS-Dyna. 

3. The input files now generated can be visually (and to some extent algorithmically) inspected by opening the Main_*.K file using the LS-PrePost executable. In general, you should get no errors or warnings at this point. 

4. If all looks good, you can either execute the simulation in the directory you created, or transfer it to a cluster. If your cluster uses the PBS job scheduler, you can issue QSUB submissionFile.sh to directly submit the job to the job scheduler.

5. At this point, the simulation should start, and you can inspect the outputs by issuing "tail -f outputScreen.txt" if you are standing in the execution directory.



## You use other people's code that you could have included, but instead you force us to make manual code changes, why?
I don't understand Intellectual Property law and I don't want someone to teach me.