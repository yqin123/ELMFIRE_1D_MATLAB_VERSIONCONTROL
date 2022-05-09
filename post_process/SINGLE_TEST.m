clear all

FUEL_TABLE_INIT;

batchrun     = true;
printoutputs = false;
saveoutputs  = false;
NUM_SIMU     = 1;
%%
OUT_EMBER_SOURCE = zeros([NUM_SIMU,1000]);
OUT_EMBER_TARGET = zeros([NUM_SIMU,1000]);
OUT_EMBER_FLUX   = zeros([NUM_SIMU,1000]);

for I_SIMU =1:NUM_SIMU
    % Meteology
    U_wind = 15; % Wind velocity, mph

    % Topography
    a_0    = 23;     % Average building plan dimension, m
    d      = 45;     % Average building seperation, m
    f_b    = 0.0;    % Ratio of fire resistance buildings
    Fuel_1 = [102   15000  30000];  % [Fuel# LeftBoundary RightBoundary] 
    Fuel_2 = [102    0     15000];  % [Fuel# LeftBoundary RightBoundary]
    M1     = 0;
    M10    = 0;
    M100   = 0;
    MLH    = 0;
    MLW    = 0;
    CC     = 0;
    CH     = 0;

    % Ember setting
    ENABLE_SPOTTING            = true;
    SPOTTING_DISTRIBUTION_TYPE = 2; % 1-, 2- 3- ,
    NEMBERS_MIN              = 1;
    NEMBERS_MAX              = 1;
    MIN_SPOTTING_DISTANCE    = 100;
    MAX_SPOTTING_DISTANCE    = 100;
    CRITICAL_SPOTTING_FIRELINE_INTENSITY =1;
    PIGN                     = 100; 
    SURFACE_FIRE_SPOTTING_PERCENT = 100;
    
    DIAG_PDF = true;
    ERR = 1 ;

    % Time settings
    SimuTime   = 60000; % Total time, s
    delT       = 30;    % Time step, s

    % Spatial settings 
    delX          = 30;            % Cell size, m
    SimuRegion    = [0 30000];  % Simulation region, m
    Ignition      = 300;              % Ignition point location, m
    BANDTHICKNESS = 5;
    filename = 'main_result';%sprintf('Batch_G%03d_P%03d_M%03d_ERR%03d',NEMBERS_MIN, PIGN, delX,ERR);
    if(~exist(filename,'dir'))
        mkdir(filename);
    end
    
%%
[EMBER_SOURCE,EMBER_TARGET,FIRE_FRONT,EMBER_FLUX,LIST_TAGGED,PHIP]=ELMFIRE_1D_FUN(...
        FUEL_MODEL_TABLE_2D                     ,...        
        U_wind                                  ,...
        a_0                                     ,...
        d                                       ,...
        f_b                                     ,...
        Fuel_1                                  ,...
        Fuel_2                                  ,...
        M1                                      ,...
        M10                                     ,...
        M100                                    ,...
        MLH                                     ,...
        MLW                                     ,...
        CC                                      ,...
        CH                                      ,...
        ENABLE_SPOTTING                         ,...
        SPOTTING_DISTRIBUTION_TYPE              ,...
        NEMBERS_MIN                             ,...
        NEMBERS_MAX                             ,...
        MIN_SPOTTING_DISTANCE                   ,...
        MAX_SPOTTING_DISTANCE                   ,...
        CRITICAL_SPOTTING_FIRELINE_INTENSITY    ,...
        PIGN                                    ,...
        SURFACE_FIRE_SPOTTING_PERCENT           ,...
        SimuTime                                ,...
        delT                                    ,...
        delX                                    ,...
        SimuRegion                              ,...
        Ignition                                ,...
        BANDTHICKNESS                           ,...
        batchrun                                ,...
        saveoutputs                             ,...    
        printoutputs                            ,...
        DIAG_PDF                                ,...
        ERR                                     , ... 
        I_SIMU)
%%
    if(~mod(I_SIMU,10))
        fprintf("Case: %d/%d. %.1f %% finished \n",I_SIMU,NUM_SIMU, I_SIMU/NUM_SIMU*100);
    end
    %OUT_EMBER_SOURCE = [OUTER_EMBER_SOURCE; EMBER_SOURCE];
    %OUT_EMBER_TARGET = [OUT_EMBER_TARGET; EMBER_SOURCE];
    %OUT_FIRE_FRONT = [OUT_FIRE_FRONT; EMBER_SOURCE];
    
    parsave(sprintf('main_result/result_%03d.mat', I_SIMU),...
        EMBER_SOURCE,EMBER_TARGET,FIRE_FRONT,LIST_TAGGED,PHIP,EMBER_FLUX);

            
end


fprintf("\n Finished ! \n")
% save(sprintf('POSTPROCESS/result/Batch_G%03d_P%03d_M%03d/results.mat',NEMBERS_MIN, PIGN, delX));