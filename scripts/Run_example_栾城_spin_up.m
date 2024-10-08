clc
clear 

% Set spatial resolution
res = 0.1; % degrees, global
% r_m = 180 / res;
% r_n = 360 / res;
r_m = 180 / res ;
r_n = 360 / res ;
% Output files folder :
% Output_folder = 'Y:/SiTHv2_out_longterm/';
% Output_folder = 'G:/LUJIAXIN/SiTHv2_out_longterm/';
% 
% if exist(Output_folder, 'dir') == 0.
%     mkdir(Output_folder);
% end

% Forcing data folder :
% Forcing_folder = 'Y:/ModelForcingData/01deg/'; 
% Forcing_folder = 'G:/LUJIAXIN/Forcing_folder/';

% Sub-folders of Focing data
% subfolder_Rn = 'Rn';
% subfolder_Preci = 'Preci';
% subfolder_Ta = 'Ta';
% subfolder_Pa = 'Pa';
% subfolder_LAI = 'LAI'; 
% subfolder_LC = 'LC';
% subfolder_VOD = 'VODCA';

% % Set georeference, for 0.25 degrees, global
% latlim = [-90,90];
% lonlim = [-180,180];
% % rasterSize = [720,1440];
% rasterSize = [1,1];
% % rasterSize = [360,720];
% RA = georefcells(latlim,lonlim,rasterSize,'ColumnsStartFrom','north');

% Load soil type
% Soilraster = load('inpara\Soilraster.mat');
% Soilraster = Soilraster.Soilraster; 
Soilraster = load('inpara\Soilraster.mat')
Soilraster = Soilraster.Soilraster(522, 2947);

% Load land mask
% maskland = load('inpara\landmask01.mat');
% maskland = uint8(maskland.mask2);
maskland = load('inpara\landmask01.mat')
maskland = maskland.mask2(522, 2947);

% Load the optimal temperature for plant growth
Topt = load('inpara\Topt.mat');
Topt = single(Topt.Topt_new);
Topt = Topt(522, 2947);

% Parallel calculation
% parpool('local', 40);
% test = load('G:/LUJIAXIN/Rn_01deg_1982-2019_daily_lc.mat');
% Main loops

i = 522; % 设定行索引
j = 2947; % 设定列索引
X_upti = zeros(1, 5);

%spin_up 
for yr = 1988
    clear waa zgww snpp
    disp(' ')

    spinfg = 1; % need spin-up
    disp(' ')
    disp('start year ... spin-up ... set spinfg = 1')

    % Initialization
    waa = 0.25 .* ones(1, 3); % initial value for swc
    zgww = 5050 .* ones(1); % initial value for groundwater table
    snpp = zeros(1); % initial value for snowpack depth

 % ----------------- %
    % Load Forcing Data %
    % ----------------- %
    % --------------------------------------------------------------------%
    % Net Radiation, W/m2
    % disp(['Load Net Radiation ... For the year :: ' num2str(yr)])
    % EMO_Rn = matfile([Forcing_folder subfolder_Rn num2str(yr) '.mat']);
    % filename = ['ERA5L_global_DAY_' num2str(yr) '_Rn.nc'];
    % EMO_Rn = ncread([Forcing_folder filename], 'Rn');
    % EMO_Rn = ncread([Forcing_folder subfolder_Rn num2str(yr) '.mat']);
    % EMO_Rn = EMO_Rn.RN; 
    folderPath = "LCZ/Rn";
    fileName = sprintf('Rn_05deg_%d.mat', yr);
    fullFileName = fullfile(folderPath, fileName);
    EMO_Rn = load(fullFileName); 
    EMO_Rn = EMO_Rn.data.value /86400;

    % Air Temperature, C, 2m
    % disp(['Load Air Temperature ... For the year :: ' num2str(yr)])
    % EMO_Ta = matfile([Forcing_folder subfolder_Ta num2str(yr) '.mat']);
    % EMO_Ta = load([Forcing_folder subfolder_Ta num2str(yr) '.mat']);
    % EMO_Ta = EMO_Ta.Ta; 
    folderPath = "LCZ/Tavg";
    fileName = sprintf('Tavg_01deg_%d.mat', yr);
    fullFileName = fullfile(folderPath, fileName);
    EMO_Ta = load(fullFileName);
    EMO_Ta = EMO_Ta.data.value - 273.15;

    % Precipitation, mm
    % disp(['Load Precipitation ... For the year :: ' num2str(yr)])
    % EMO_Preci = matfile([Forcing_folder subfolder_Preci num2str(yr) '.mat']);
    % EMO_Preci = load([Forcing_folder subfolder_Preci num2str(yr) '.mat']);
    % EMO_Preci = EMO_Preci.P; 
    folderPath = "LCZ/Prcp";
    fileName = sprintf('Prcp_01deg_%d.mat', yr);
    fullFileName = fullfile(folderPath, fileName);
    EMO_Preci =  load(fullFileName); 
    EMO_Preci = EMO_Preci.data.value * 1000;

    % Air Pressure, kPa
    % disp(['Load Air Pressure ... For the year :: ' num2str(yr)])
    % EMO_Pa = matfile([Forcing_folder subfolder_Pa num2str(yr) '.mat']);
    % EMO_Pa = load([Forcing_folder subfolder_Pa num2str(yr) '.mat']);
    % EMO_Pa = EMO_Pa.Pa;
    folderPath = "LCZ/Pa";
    fileName = sprintf('Pa_01deg_%d.mat', yr);
    fullFileName = fullfile(folderPath, fileName);
    EMO_Pa =  load(fullFileName);
    EMO_Pa = EMO_Pa.data.value / 1000;

    % Satellite-based LAI
    % disp(['Load Satellite-based LAI  ... For the year :: ' num2str(yr)])
    % EMO_LAI = matfile([Forcing_folder subfolder_LAI num2str(yr) '.mat']);
    % EMO_LAI = load([Forcing_folder subfolder_LAI num2str(yr) '.mat']);
    % EMO_LAItime = EMO_LAI.tt; 
    % EMO_LAI = EMO_LAI.LAIx; 
    folderPath = "LCZ/LAI";
    fileName = sprintf('LAI_01deg_%d.mat', yr);
    fullFileName = fullfile(folderPath, fileName);
    EMO_LAI =  load(fullFileName);
    EMO_LAI = EMO_LAI.data.value;

    % Satellite-based VOD
    % disp('Load Satellite-based VOD  ...')
    % EMO_VOD = matfile([Forcing_folder subfolder_VOD num2str(yr) '.mat']);
    % EMO_VOD = load([Forcing_folder subfolder_VOD num2str(yr) '.mat']);
    % EMO_VOD = EMO_VOD.VODCAy;
    folderPath = "LCZ/VOD";
    fileName = sprintf('VOD_025deg_%d.mat', yr);
    fullFileName = fullfile(folderPath, fileName);
    EMO_VOD =  load(fullFileName);
    EMO_VOD = EMO_VOD.data.VOD;

    % Satellite-based Landcover/PFTs
    % disp(['Load Satellite-based Landcover  ... For the year :: ' num2str(yr)])
    % LC_year = load([Forcing_folder subfolder_LC num2str(yr) '.mat']);
    % LC_year = LC_year.LULC; 

    LC_year =  load("LCZ/LULC/LULC_001deg_1982_2019.mat");
    % LC_year = LC_year.data.value;
    LC_year = 22;
    % --------------------------------------------------------------------%
    
    % Days of selected year
    % days = yeardays(yr); %年份的天数
    days = yeardays(yr); %年份的天数

    % ------------------ %
    % Parallel Computing %
    % ------------------ %

    disp('Preallocate memory to each variables ... ')
    % 10 variables
    % X_ET  = zeros(r_m, r_n, days,'double');
    % X_Tr  = zeros(r_m, r_n, days,'double');
    % X_Es  = zeros(r_m, r_n, days,'double');
    % X_Ei  = zeros(r_m, r_n, days,'double');
    % X_Esb = zeros(r_m, r_n, days,'double');
    % X_SM1 = zeros(r_m, r_n, days,'double');
    % X_SM2 = zeros(r_m, r_n, days,'double');
    % X_SM3 = zeros(r_m, r_n, days,'double');
    % X_RF  = zeros(r_m, r_n, days,'double');
    % X_GW  = zeros(r_m, r_n, days,'double');
    
    disp('Start calculation ... ')
    % X_upt = zeros(r_m, r_n, 5);


    Rnix = (EMO_Rn); %重新排列
    Taix = (EMO_Ta);
    Precix = (EMO_Preci);
    Paix = (EMO_Pa);
    LAIix = (EMO_LAI);
    VODix = (EMO_VOD);

    X_vals = zeros(days, length(1988:1998), 10); % 仅处理一个列
    % X_upti = zeros(1, length(1988:1998), 5); % 仅处理一个列

    wa = reshape(waa(1, :), [1, 3]); % 三个层深
    zgw = zgww(1);
    snp = snpp(1);

    % 气象强迫处理
    Rni = 0.01 .* double(Rnix);
    Tai = 0.01 .* double(Taix);
    Precii = 0.01 .* double(Precix);            
    Pai = 0.01 .* double(Paix);

    % 计算 Tas
    Tasi = Tai;
    Tasi(Tasi < 0) = 0; % 去除小于0的值
    Tasi = cumsum(Tasi); % 求累积和

    % 卫星 LAI 处理
    LAIi = 0.01 .* double(LAIix);
    folderPath = "LCZ/LAI";
    fileName = sprintf('LAI_01deg_%d.mat', yr);
    fullFileName = fullfile(folderPath, fileName);
    EMO_LAItime =  load(fullFileName);
    EMO_LAItime = EMO_LAItime.data.time;
    EMO_LAItime_dt = datetime(EMO_LAItime, 'InputFormat', 'yyyyMMdd');
    xo = day(EMO_LAItime_dt, "dayofyear"); % 一年的天数
    xi = 1:1:days;
    LAIii = interp1(xo', LAIi, xi', 'pchip', 'extrap'); % 8天插值为每日
    LAIii(LAIii < 0) = 0;

    % 计算 G_soil
    Gi = 0.4 .* Rni .* exp(-0.5 .* LAIii);

    % 计算 VOD-stress
    VODi = 0.001 .* double(VODix);
    VODi(VODi < 0) = 0;
    s_VODi = (VODi ./ max(VODi)).^0.5;

    % Topt
    Top = Topt; 

    % 参数设置
    PFTi = LC_year;
    pftpar = get_pftpar(PFTi);
    SC = Soilraster;
    soilpar = get_soilpar(SC);

    wa(wa < 0) = 0.01; 


    % ------------------ Call SiTHv2 ------------------------------
    [ETi, Tri, Esi, Eii, Esbi, SMi, RFi, GWi, snpx] = cal_SiTHv2(Rni,...
        Tai, Tasi, Precii, Pai, Gi, LAIii, Top, s_VODi, ...
        soilpar, pftpar, wa, zgw, snp, spinfg);
    % ------------------ Call SiTHv2 ------------------------------

end

X_upti(:, 1) = SMi(end, 1);
X_upti(:, 2) = SMi(end, 2);
X_upti(:, 3) = SMi(end, 3);
X_upti(:, 4) = GWi(end, 1);
X_upti(:, 5) = snpx; % 假设 snpx 是一个固定值
save('output_data_spin.mat', 'X_upti');