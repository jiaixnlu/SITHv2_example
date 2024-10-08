% ------------------------ %
%     Snowpack balance     %
% ------------------------ %
% function [snowpack, Esb, snowmelt, Pnet] = snp_balance(preci, Ta, Tas,snowpack, pEs)
% #修改preci为new_Pe, snowpack为snp
function [snp, Esb, snowmelt, Pnet] = snp_balance(new_Pe, Ta, Tas, snp, pEs)
% snowpack :: available snow storage
% snowmelt :: snow melt
% Esb      :: snow sublimation

% Esnow_emp = 0.84.*(0.864 .* (7.093 .* Ta + 28.26)) ./ (Ta.^2 - 3.593 .* Ta + 5.175);
Esnow = pEs; % Simple equivalent (Needs further development)

% only snowfall occurs at Ta below zero
if Ta <= 0
    
    % Add new snowfall, Ta<=0
    newsnow = new_Pe;
    snp = snp + newsnow;
    
    % snon melt
    snowmelt = 0;
    
    % real snow sublimation
    Esb = min(snp, Esnow);
    Esb = max(Esb, 0); % >0
    
    % net Precipitation into soil surface
    Pnet = 0;

    % new snowpack
    snp = snp - Esb;
    
else
    
    % real snow sublimation
    Esb = min(snp, Esnow);
    Esb = max(Esb, 0);

    snp = snp - Esb;

    % snow melt, Ta>0
    snowmelt_x = (1.5 + 0.007 * new_Pe) * Tas; % Tas, accumulated Ta > 0
    snowmelt = min(snp, snowmelt_x);
    snp = snp - snowmelt;
    
    % net water into soil surface
    Pnet = max(0, new_Pe + snowmelt);
    
end

end
