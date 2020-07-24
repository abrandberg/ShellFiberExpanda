function angXZ = orientFiber(physicsControl,ctrl)
%function angXZ = orientFiber(physicsControl,ctrl) introduces anisotropy in the
%fiber orientation, causing the sheet to have orthotropic properties.
% 
% INPUTS:       physicsControl.lambda   - Ratio Ex/Ey (elastic moduli)
%               ctrl                    - Control structure, not needed right now
%
% OUTPUTS:      angXZ                   - Angle in the plane of the fiber
%
% ABOUT:
% There are many ways to model the structural anisoptropy. This method was one of the
% easiest but has fallen out of fashion. The implementation is based on 
%
% MARK, Richard E., et al. (ed.). Handbook of physical testing of paper. Crc Press, 2002.
% Chapter 16, p. 910 which is in turn based on:
%
% Forgacs, O.L. and Strelis, I. (1963). The measurement of the quantity and orientation of
% chemical pulp fibres in the surfaces of newsprint. Pulp Paper Mag. Can. 64(1):T3-T13.
%
% TO DO:
%
% created by: August Brandberg august at kth . se
% date: 26-10-2019
%
%
% PROOF OF CONCEPT:
% ctrl.fileSep = '\';
% for bLoop = 1:5
%     physicsControl.lambda = bLoop;
%     for aLoop = 1:1000000
%         angXZ(aLoop) = orientFiber(physicsControl,ctrl);
%     end
% %     subplot(1,2,1)
%     histogram(angXZ,360,'displaystyle','stairs','Normalization','probability')
%     hold on
%     t = -89:270;
% %     subplot(1,2,2)
%     plot(t,0.5/57.6*physicsControl.lambda./pi.*(1./(cosd(t).^2+physicsControl.lambda.^2.*sind(t).^2)),'-.')
% end
% xlabel('\theta_{xz}'); ylabel('PDF')

rVal = rand(1);
tVal = rand(1);

if tVal > 0.5
    angXZ = rad2deg(atan(tan(pi.*(rVal-0.5))./physicsControl.lambda));
else
    angXZ = mod(rad2deg(atan(tan(pi.*(rVal-0.5))./physicsControl.lambda))-180,360);
end

