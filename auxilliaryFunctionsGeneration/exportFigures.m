function exportFigures(ctrl)
%function exportFigures(ctrl) exports images in PNG format.
%
% INPUTS:       ctrl        - Contains various choices that control the simulation.
%                             Of particular interest is ctrl.plotFlag which controls
%                             whether plots are saved to disk.
%
% OUTPUTS:      none
%
% ABOUT:
%
% TO DO:
%
% created by: August Brandberg augustbr at kth . se
% date: 26-10-2019

if ctrl.plotFlag
    
    disp('-> SAVING IMAGES')
    mkdir(ctrl.plotDirectory)
    FigIdx = findall(0, 'type', 'figure');
    for mm = 1:length(FigIdx)
        figure(mm)
        foo = get(gcf,'Name');
        foo = strrep(foo, '.', ',');
        print(foo,'-dpng','-r600')    
        movefile(horzcat(foo,'.png'),horzcat(ctrl.plotDirectory,ctrl.fileSep,foo,'.png'))
    end
end
