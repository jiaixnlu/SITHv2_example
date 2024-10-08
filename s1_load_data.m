% Set spatial resolution
i = 522;
j = 2947;

% 0.1 deg
Soilraster = load('inpara\Soilraster.mat').Soilraster;
soil_type = Soilraster(i, j);

maskland = load('inpara\landmask01.mat').mask2;
maskland = maskland.mask2(i, j);

% Load the optimal temperature for plant growth
Topt = load('inpara\Topt.mat');
Topt = single(Topt.Topt_new);
Topt = Topt(i, j);

df = readtable("data/dat_栾城_ERA5L_1982-2019.csv");
nyear = 2016 - 1988 + 1;

%% model parameters 
Top = Topt;
PFTi = 22; % Land cover type
pftpar = get_pftpar(PFTi);
soilpar = get_soilpar(soil_type);

% retrieve data
dates = df.date;
years = year(date);

%% 创建一个结构体，存放状态变量
% 状态变量需要连续，传递到下一年中
uptval = load('output_data_spin.mat').X_upti;
SM = uptval(1, 1:3);
ZG = uptval(1, 4);
snowpack = uptval(1, 5);
State = struct();
State = update_state(State, SM, ZG, snowpack);
