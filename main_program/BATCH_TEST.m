clearvars -except NEMBERS_MIN NEMBERS_MAX GR i j BATCH_NAME DX delX
% clearvars -except DX delX i j BATCH_NAME
% clear
% !rmdir main_result
% !rmdir ember_result
% !rmdir prop_log
% parpool

FUEL_TABLE_INIT;

batchrun     = true;
printoutputs = false;
saveoutputs  = false;
NUM_SIMU     = 10;
%%
OUT_EMBER_SOURCE = zeros([NUM_SIMU,1000]);
OUT_EMBER_TARGET = zeros([NUM_SIMU,1000]);
OUT_EMBER_FLUX   = zeros([NUM_SIMU,1000]);

% parfor I_SIMU =1:NUM_SIMU
for I_SIMU =1:NUM_SIMU
    % Meteology
    U_wind = 15; % Wind velocity, mph

    % Topography
    a_0    = 23;     % Average building plan dimension, m
    d      = 45;     % Average building seperation, m
    f_b    = 0.0;    % Ratio of fire resistance buildings
    Fuel_1 = [103  1 300];  % [Fuel# LeftBoundary RightBoundary] 
    Fuel_2 = [102   0  1];  % [Fuel# LeftBoundary RightBoundary]
    M1     = 0;
    M10    = 0;
    M100   = 0;
    MLH    = 0;
    MLW    = 0;
    CC     = 0;
    CH     = 0;

    % Ember setting
    ENABLE_SPOTTING            = true;
    EMBER_ALL_ACTIVATED        = true;
    SPOTTING_DISTRIBUTION_TYPE = 2; % 1-, 2- 3- ,
    NEMBERS_MIN              = 100; % embers/cell/s
    NEMBERS_MAX              = 100; % embers/cell/s
    MIN_SPOTTING_DISTANCE    = 100;
    MAX_SPOTTING_DISTANCE    = 100;
    CRITICAL_SPOTTING_FIRELINE_INTENSITY =1;
    PIGN                     = 100;
    SURFACE_FIRE_SPOTTING_PERCENT = 100;
    
    DIAG_PDF = true;
    ERR = 100 ;
    
    % Time settings
    SimuTime   = 1000; % Total time, s
    delT       = 0.14;    % Time step, s
    FORCE_DT   = delT;  % set to 0 when unwanted

    % Spatial settings 
    delX          = 1;            % Cell size, m
    SimuRegion    = [0 300];      % Simulation region, m
    Ignition      = 0;            % Ignition point location, m
    BANDTHICKNESS = 2;
    filename = 'main_result';%sprintf('Batch_G%03d_P%03d_M%03d_ERR%03d',NEMBERS_MIN, PIGN, delX,ERR);
    if(~exist(filename,'dir'))
        mkdir(filename);
    end
    
%%
[EMBER_SOURCE,EMBER_FLUX,LIST_TAGGED,PHIP,TIME_TO_IGNITE, EMBER_EMIT_FLUX,TIME_OF_ARRIVAL]=...
    ELMFIRE_1D_FUN(...
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
        ERR                                     ,... 
        I_SIMU                                  ,...
        FORCE_DT                                ,...
        EMBER_ALL_ACTIVATED);
%%
    if(~mod(I_SIMU,10))
        fprintf("Case: %d/%d. %.1f %% finished \n",I_SIMU,NUM_SIMU, I_SIMU/NUM_SIMU*100);
    end
    %OUT_EMBER_SOURCE = [OUTER_EMBER_SOURCE; EMBER_SOURCE];
    %OUT_EMBER_TARGET = [OUT_EMBER_TARGET; EMBER_SOURCE];
    %OUT_FIRE_FRONT = [OUT_FIRE_FRONT; EMBER_SOURCE];
    
    parsave(sprintf('main_result/result_%03d.mat', I_SIMU),...
        TIME_TO_IGNITE,EMBER_EMIT_FLUX,TIME_OF_ARRIVAL,LIST_TAGGED,PHIP,EMBER_FLUX);

            
end

fprintf("\n Simulation Finished ! \n")
% save(sprintf('POSTPROCESS/result/Batch_G%03d_P%03d_M%03d/results.mat',NEMBERS_MIN, PIGN, delX));

%% Post Process
fprintf("\n Post Processing ! \n")

phi_BACK=-0.9;
phi_FRONT=0.95;

SIMU_REGION_IND = [1:length(SimuRegion(1):delX:SimuRegion(2))]+2;
for I_SIMU=1:NUM_SIMU
    filename=sprintf("prop_log/prop_log_%03d.csv",I_SIMU);
    filename_ember=sprintf("ember_result/ember_result_%03d.csv",I_SIMU);
    filename_ember_flux=sprintf("ember_flux_log/ember_flux_%03d.csv",I_SIMU);
    prop_log = dlmread(filename,'\t');
    time = prop_log(:,1);
    prop_map = prop_log(:,2:end);
    
    SIGNAL_AVG_OPERATOR = diag(ones([1,length(SIMU_REGION_IND)]));%+diag(ones([1,length(SIMU_REGION_IND)-1]),-1);%+diag(ones([1,length(SIMU_REGION_IND)-2]),-2);
    
    for n = 1:length(time)
        pm_temp=(prop_map(n,SIMU_REGION_IND)*SIGNAL_AVG_OPERATOR);
        BACK_BOUND_IX = find(pm_temp>phi_BACK);
        FRONT_BOUND_IX = find(pm_temp<phi_FRONT);
        
%         if(length(FRONT_BOUND_IX)<1)
%             FRONT_BOUND_IX=103;
%         end
%         if(length(BACK_BOUND_IX)<1)
%             BACK_BOUND_IX=103;
%         end
        if(length(FRONT_BOUND_IX)<1)
            if n==1
                FIRE_FRONT_IX(n) = SIMU_REGION_IND(1);
                FIRE_BACK_IX(n)  = SIMU_REGION_IND(1);
            else
                FIRE_FRONT_IX(n) = SIMU_REGION_IND(end);
                FIRE_BACK_IX(n)  = SIMU_REGION_IND(end);
            end
        elseif(length(BACK_BOUND_IX)<1)
            if n==1
                FIRE_FRONT_IX(n) = SIMU_REGION_IND(1);
                FIRE_BACK_IX(n)  = SIMU_REGION_IND(1);
            else
                FIRE_FRONT_IX(n) = SIMU_REGION_IND(end);
                FIRE_BACK_IX(n)  = SIMU_REGION_IND(end);
            end
        else
            FIRE_FRONT_IX(n) = FRONT_BOUND_IX(end);
            FIRE_BACK_IX(n)  = BACK_BOUND_IX(1);
        end
    %     fprintf("front: %d, Back: %d\n",FIRE_FRONT_IX,FIRE_BACK_IX);
    %     if(sum(pm_temp(end-3:end))<3)
    %         LAST_CELL_ARRIVAL_TIME = time(n)
    %         break
    %     end
        LAST_CELL_ARRIVAL_TIME = time(n);
        if(pm_temp(end)<0)
            break
        end
    end
    
    if(exist(filename_ember,'file'))
        EMBER_STAT = dlmread(filename_ember,'\t');
        [e1,e2]=find(EMBER_STAT~=0);
        EMBER_STAT(:,max(e2)+1:end)=[];
    end
    if(exist(filename_ember_flux,'file'))
        EMBER_FLUX_HIST = dlmread(filename_ember_flux,'\t');
        save(sprintf('main_result/result_%03d.mat', I_SIMU),'EMBER_FLUX_HIST','-append');
%         clear('EMBER_FLUX_HIST')
        delete(filename_ember_flux);
    end

    if(exist(filename,'file'))
        save(sprintf('main_result/result_%03d.mat', I_SIMU),...
            'delT','prop_log','LAST_CELL_ARRIVAL_TIME','FIRE_FRONT_IX','FIRE_BACK_IX','-append');
        clear('prop_log','LAST_CELL_ARRIVAL_TIME','FIRE_FRONT_IX','FIRE_BACK_IX')
        delete(filename);
    end
    if(exist(filename_ember,'file'))
        save(sprintf('main_result/result_%03d.mat', I_SIMU),'EMBER_STAT','-append');
        clear('EMBER_STAT')
        delete(filename_ember);
    end
end
if(exist('prop_log','dir'))
    rmdir('prop_log');
end
if(exist('ember_result','dir'))
    rmdir('ember_result')
end
fprintf("\n End ! \n")