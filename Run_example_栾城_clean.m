%% 栾城站: 模型测试
% kongdd, CUG, 2024-10-08
clc, clear;

s1_load_data
X_vals = zeros(days, nyear, 10); % 仅处理一个列

for yr = 1989:2016;
  k = yr - 1988 + 1; % 因为1988是第一年，索引从1开始
  spinfg = 0;
  disp('normal year ... set spinfg = 0')

  days = yeardays(yr); %年份的天数
  num_days = length(xi); % 获取该年的天数
  
  inds = find(years == yr);
  d = df(inds, :);
  Rn   = d.Rn;
  Ta   = d.Tavg;
  Prcp = d.Prcp;
  Pa   = d.Pa;
  LAI  = d.LAI;
  VOD  = d.VOD;

  % 全球运行过程中，wa: [nlon, nlat, nlys]
  % 站点运行: wa: [1, nlys]
  wa = reshape(waa(1, :), [1, 3]); % 三个层深
  wa(wa < 0) = 0.01;
  
  zgw = zgww(1);
  snp = snpp(1);
  
  % 计算 Tas：有效积温
  Tas = Ta;
  Tas(Tas < 0) = 0; % 去除小于0的值
  Tas = cumsum(Tas); % 求累积和
  
  Gi = 0.4 .* Rni .* exp(-0.5 .* LAI); % G_soil
  s_VODi = (VOD ./ max(VOD)).^0.5; % VOD-stress
  
  [ETi, Tri, Esi, Eii, Esbi, SMi, RFi, GWi, snpx] = cal_SiTHv2(Rni,...
    Tai, Tasi, Precii, Pai, Gi, LAIii, Top, s_VODi, ...
    soilpar, pftpar, wa, zgw, snp, spinfg);
  
  x_val(1:num_days, k, 1) = ETi(1:num_days); % ET
  x_val(1:num_days, k, 2) = Tri(1:num_days); % Tr
  x_val(1:num_days, k, 3) = Esi(1:num_days); % Es
  x_val(1:num_days, k, 4) = Eii(1:num_days); % Ei
  x_val(1:num_days, k, 5) = Esbi(1:num_days); % Esb
  x_val(1:num_days, k, 6) = SMi(1:num_days, 1); % SM1
  x_val(1:num_days, k, 7) = SMi(1:num_days, 2); % SM2
  x_val(1:num_days, k, 8) = SMi(1:num_days, 3); % SM3
  x_val(1:num_days, k, 9) = RFi(1:num_days); % RF
  x_val(1:num_days, k, 10) = GWi(1:num_days); % GW  
  %% 
end
