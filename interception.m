% -------------------------- %
%  Interception evaporation  %
% -------------------------- %
% function [Ei,wetT,Pe] =
% interception(pEc,LAI,Rain,pftpar)#修改,wetT替换为fwet；Rain替换为Pe
function [Ei,fwet,Pe] = interception(LAI, Pe, pEc, pftpar)
% ------- function input -------
% pEc    : potnetial Evaporation on canopy
% Rain   :
% LAI    : Leaf area index
% PFTpar : PFT parameters
% ------- function output ------
% Ei     : Interception envaporation, mm/day
% wet    : wetness fraction
% -------
% Reference:
% Choudhury BJ, Digirolamo NE, 1998, A biologisical process-based estimate
% of global land surface evaporation using satellite and ancillary data I.
% Model description and comparison with observation. Journal of Hydrology.
%
% Interception (I, mm) was calculated using Horton's model:
%   I       =   min(P,aP+b)
% Where P   =   precipitation in mm
%  a,b      =   parameters with values derived from published records
% -------------------------------------------------------------------------

% x, parameter values, used for calculating daily rainfall interception
inc = pftpar(1);
Sc = min(Pe, inc.*LAI.*Pe); 

fwet = min(0.7.*Sc./pEc,1); 

if pEc < 1e-3

    Ei = 0;
else
    Ei = pEc.*fwet; 
end

Pe = Pe - Ei;

end