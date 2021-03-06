function [EMBER_SOURCE,EMBER_FLUX,LIST_TAGGED,PHIP,TIME_TO_IGNITE, EMBER_EMIT_FLUX, TIME_OF_ARRIVAL]=ELMFIRE_1D_FUN(...
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
        EPS_MAX                                 ,...
        I_SIMU                                  ,...
        FORCE_DT                                ,...
        EMBER_RES_TIME                          ,...
        EMBER_TRAVEL_BY_WIND                    ,...
        RES_DIR)

% Solver for 1-D fire propagation test, coupling with Rothermel model, 
% Hamada model and  various firebrand model

%% Model Initializing

SimuMap = [0,0,SimuRegion(1):delX:SimuRegion(2),0,0];
NX      = length(SimuMap);
FuelMap = zeros(size(SimuMap));
FuelMap(SimuMap >= Fuel_1(2) & SimuMap <= Fuel_1(3)) = Fuel_1(1);
FuelMap(SimuMap >= Fuel_2(2) & SimuMap <= Fuel_2(3)) = Fuel_2(1);

M1     = zeros(size(SimuMap))+M1;
M10    = zeros(size(SimuMap))+M10;
M100   = zeros(size(SimuMap))+M100;

CC     = zeros(size(SimuMap))+CC;
CH     = zeros(size(SimuMap))+CH;

SURFACE_FIRE_SPOTTING_PERCENT=SURFACE_FIRE_SPOTTING_PERCENT+zeros([1,256]);
SURFACE_FIRE_SPOTTING_PERCENT(103)=0;

T_IGN = 0.0;
IX_IGN = ceil(Ignition/delX)+2;IX_IGN = max(3,IX_IGN);IX_IGN=min(NX-2,IX_IGN);

PHIP = ones(size(SimuMap));
PHIP = PHIP+(0.5-rand(size(PHIP)))*1e-4;
PHIP([1,2,end-1,end]) = -1;
PHIP(IX_IGN) = -1; 
PHIP_OLD = PHIP;
SURFACE_FIRE   = zeros(size(SimuMap));
TIME_OF_ARRIVAL= zeros(size(SimuMap))+9999;

T = 0;

NUM_EVERTAGGED = 0;
TAGGED         = zeros(size(SimuMap));
EVERTAGGED     = zeros(size(SimuMap));

EVERTAGGED_IX   = zeros([1 10000]);
ALREADY_IGNITED = zeros([1 10000]);
IX_TO_TAG       = zeros([1 10000]);

RCELLSIZE       = 1. / delX;
HALFRCELLSIZE   = 1./(2*delX);
NUM_IGNITIONS = 1;

LIST_TAGGED=[];
DT = delT;

MAX_LOW = 8;
I = 2:100001;
WSMFEFF=(I-1) * 0.1;
LOW_FROM_WSMFEFF = [1,min( 0.936*exp(0.2566*WSMFEFF*60./5280.) + ...
  0.461*exp(-0.1548*WSMFEFF*60.0/5280.) - 0.397, MAX_LOW)];

I = 1002:20001;
LOW = (I-1) * 0.001;
BOH_FROM_LOW = [ones([1,1001]),1.0 ./ ((LOW + sqrt(LOW.*LOW - 1.0)) ./...
  (LOW - sqrt(LOW.*LOW -1.0)))];

WAF=CALC_WIND_ADJUSTMENT_FACTOR_EVERYWHERE(CC, CH, FuelMap, FUEL_MODEL_TABLE_2D, NX);

EMBER_FLUX=zeros(size(SimuMap));
EMBER_FLUX_HIST=zeros(size(SimuMap));
% IX_SPOT_FIRE = zeros([1,10000]);

% Ember ignition time correction
TIME_TO_IGNITE = zeros(size(SimuMap))+9999;
SPOT_IGNITION = zeros(size(SimuMap));

% IX_SUB=ones([1,6000000]);

EMBER_SOURCE = [];
% EMBER_TARGET = [];
% FIRE_FRONT   = [];
EMBER_EMIT_FLUX = zeros(size(PHIP));

SOURCE = [zeros(size(SimuMap));zeros(size(SimuMap));zeros(size(SimuMap));zeros(size(SimuMap));zeros(size(SimuMap))];

%%
% Generate new folder, containing all outputs, free from covering previous
% results.

PROP_LOG_DIR=strcat(RES_DIR,'/prop_log');
if(~exist(PROP_LOG_DIR,'dir'))
    mkdir(PROP_LOG_DIR)
end

log_bin=[PROP_LOG_DIR,sprintf('/prop_log_%03d.bin',I_SIMU)];

% N_SPOT_FIRES = 0;
while(T < SimuTime)
    
    if(~exist(log_bin,'file'))
        FileID=fopen(log_bin,'w');
    else
        FileID=fopen(log_bin,'a');
    end
    VAR_TO_WRITE=double([T,PHIP]);
    fwrite(FileID,VAR_TO_WRITE,'double');
    fclose(FileID);
    
    T = T + DT;
    if (NUM_IGNITIONS > 0) 
        for I = 1:NUM_IGNITIONS
            if (ALREADY_IGNITED(I)) 
                PHIP    (IX_IGN) = -1.0;
                PHIP_OLD(IX_IGN) = -1.0;
                continue
            end
            if (T >= T_IGN(I)) 
                ALREADY_IGNITED(I) = true;
                IXLOC  = IX_IGN;
                [LIST_TAGGED, TAGGED, EVERTAGGED, NUM_EVERTAGGED, EVERTAGGED_IX] =...
                    TAG_BAND(NX, IXLOC, T, LIST_TAGGED, TAGGED, EVERTAGGED, NUM_EVERTAGGED,...
                    EVERTAGGED_IX, BANDTHICKNESS, FuelMap, M1, M10, M100, MLH, MLW, U_wind, WAF);
                PHIP    (IX_IGN) = -1.0;
                PHIP_OLD(IX_IGN) = -1.0;
            end
        end
    end
    PHIP    (FuelMap==92) = -1.0;
    PHIP_OLD(FuelMap==92) = -1.0;
    LIST_TAGGED = SURFACE_SPREAD_RATE(LIST_TAGGED,FUEL_MODEL_TABLE_2D);
    
    for ISTEP=1:2
        
        [LIST_TAGGED, PHIP_OLD] = CALC_NORMAL_VECTORS(ISTEP, LIST_TAGGED,HALFRCELLSIZE, PHIP, PHIP_OLD);
        
        LIST_TAGGED = UX_AND_UY_ELLIPTICAL(LIST_TAGGED,ISTEP,SURFACE_FIRE, FUEL_MODEL_TABLE_2D, ...
                                            1.0, LOW_FROM_WSMFEFF, BOH_FROM_LOW,...
                                            U_wind, a_0, d, f_b);
        
        if(ISTEP==1)
            DT = CALC_CFL(LIST_TAGGED,DT,delX,delT, FORCE_DT); 
        end
        LIST_TAGGED=LIMIT_GRADIENTS(LIST_TAGGED,PHIP,RCELLSIZE);
        PHIP=RK2_INTEGRATE(LIST_TAGGED,DT,ISTEP,PHIP,PHIP_OLD);
    end
    % Find newly-burned cells and call spotting:
    N_TO_TAG = 0;
    
    N_SPOT_FIRES = 0;
    IX_SPOT_FIRE = [];
    
    C = LIST_TAGGED;
    LIST_LENGTH = length(LIST_TAGGED);

    for I = 1:LIST_LENGTH
        IX = C(I).IX;
        
        if (PHIP(IX) <= 0. && SURFACE_FIRE(IX) == 0 ) % This need to be modified, because cells ignited by embers cannot emit embers
            C(I).BURNED           = true;
            C(I).TIME_OF_ARRIVAL  = T;
            SURFACE_FIRE   (IX) = 1;
            TIME_OF_ARRIVAL(IX) = T;

            N_TO_TAG = N_TO_TAG + 1;
            IX_TO_TAG(N_TO_TAG) = IX;
            
            FMT=FUEL_MODEL_TABLE_2D(C(I).IFBFM,30);
            FMT=cell2mat(FMT);
            RES_TIME=FMT.TAU*60;
            BURN_TIME=T-TIME_OF_ARRIVAL(IX);
            
            if (ENABLE_SPOTTING && ~EMBER_RES_TIME && BURN_TIME<=RES_TIME) 

                CALL_SPOTTING = false;
                SPOT_FREQ = min(1,NEMBERS_MIN*DT);
                if (C(I).FLIN_SURFACE >= CRITICAL_SPOTTING_FIRELINE_INTENSITY)
                    R0=rand(1);
                    if (R0 < 0.01*SURFACE_FIRE_SPOTTING_PERCENT(FuelMap(C(I).IX))*SPOT_FREQ) 
                        CALL_SPOTTING = true;
                    end
                end

                if (CALL_SPOTTING) 
                    
                    % Ember ignition time correction
                    TRUE_GR = NEMBERS_MIN*DT;
                    if(TRUE_GR>1)
                        RESIDUAL = mod(TRUE_GR,1);
                        EMBER_RES = 0;R0=rand(1);
                        if (R0 < RESIDUAL) 
                            EMBER_RES = 1;
                        end
                        NEMBERS_MIN_CURRENT=floor(TRUE_GR)+EMBER_RES; % embers/cell/torch
                        NEMBERS_MAX_CURRENT=floor(TRUE_GR)+EMBER_RES; % embers/cell/torch
                    else
                        NEMBERS_MIN_CURRENT=ceil(TRUE_GR); % embers/cell/torch
                        NEMBERS_MAX_CURRENT=ceil(TRUE_GR); % embers/cell/torch
                    end

    %                     NEMBERS_MIN_CURRENT=ceil(NEMBERS_MIN*delX); % embers/cell/torch
    %                     NEMBERS_MAX_CURRENT=ceil(NEMBERS_MAX*delX); % embers/cell/torch

                    [N_SPOT_FIRES, IX_SPOT_FIRE, TIME_TO_IGNITE, EMBER_FLUX, EMBER_SOURCE,SOURCE]=...
                        SPOTTING(T, DT, IX,U_wind,C(I).FLIN_SURFACE,N_SPOT_FIRES, ...
                               SPOTTING_DISTRIBUTION_TYPE, NEMBERS_MIN_CURRENT,...
                               NEMBERS_MAX_CURRENT,NX, 0, delX, SimuTime, ...
                               PIGN, PHIP, MIN_SPOTTING_DISTANCE, ...
                               MAX_SPOTTING_DISTANCE, EMBER_FLUX, ...
                               IX_SPOT_FIRE, TIME_TO_IGNITE, EMBER_SOURCE, EPS_MAX,SOURCE, RES_DIR);
               
                    EMBER_EMIT_FLUX(IX)=EMBER_EMIT_FLUX(IX)+NEMBERS_MIN_CURRENT;
                end
            end
            
        end
        
        % -----------------Spotting during Residence Time-----------------%
        FMT=FUEL_MODEL_TABLE_2D(C(I).IFBFM,30);
        FMT=cell2mat(FMT);
        RES_TIME=FMT.TAU*60; % Residence time defined in FBFM_LABELED.csv is in minutes
        BURN_TIME=T-TIME_OF_ARRIVAL(IX);
        
        if (EMBER_RES_TIME && ENABLE_SPOTTING) 

            if(PHIP(IX)<=0 && BURN_TIME<RES_TIME)

                CALL_SPOTTING = false;

                SPOT_FREQ = min(1,NEMBERS_MIN*DT);
                if (C(I).FLIN_SURFACE >= CRITICAL_SPOTTING_FIRELINE_INTENSITY)
                    R0=rand(1);
                    if (R0 < 0.01*SURFACE_FIRE_SPOTTING_PERCENT(FuelMap(C(I).IX))*SPOT_FREQ) 
                        CALL_SPOTTING = true;
                    end
                end

                if (CALL_SPOTTING) 
                    % Ember ignition time correction
                    TRUE_GR = NEMBERS_MIN*DT;
                    if(TRUE_GR>1)
                        RESIDUAL = mod(TRUE_GR,1);
                        EMBER_RES = 0;R0=rand(1);
                        if (R0 < RESIDUAL) 
                            EMBER_RES = 1;
                        end
                        NEMBERS_MIN_CURRENT=floor(TRUE_GR)+EMBER_RES; % embers/cell/torch
                        NEMBERS_MAX_CURRENT=floor(TRUE_GR)+EMBER_RES; % embers/cell/torch
                    else
                        NEMBERS_MIN_CURRENT=ceil(TRUE_GR); % embers/cell/torch
                        NEMBERS_MAX_CURRENT=ceil(TRUE_GR); % embers/cell/torch
                    end
    %                     
                    [N_SPOT_FIRES, IX_SPOT_FIRE, TIME_TO_IGNITE, EMBER_FLUX, EMBER_SOURCE,SOURCE]=...
                        SPOTTING(T, DT, IX,U_wind,C(I).FLIN_SURFACE,N_SPOT_FIRES, ...
                               SPOTTING_DISTRIBUTION_TYPE, NEMBERS_MIN_CURRENT,...
                               NEMBERS_MAX_CURRENT,NX, 0, delX, SimuTime, ...
                               PIGN, PHIP, MIN_SPOTTING_DISTANCE, ...
                               MAX_SPOTTING_DISTANCE, EMBER_FLUX, ...
                               IX_SPOT_FIRE, TIME_TO_IGNITE, EMBER_SOURCE, EPS_MAX, SOURCE, RES_DIR);
                    
                    EMBER_EMIT_FLUX(IX)=EMBER_EMIT_FLUX(IX)+NEMBERS_MIN_CURRENT;
                end
            end
        end
        % -----------------End of Spotting during Residence Time-----------------%
    end
    LIST_TAGGED=C;
    
    for I = 1: N_TO_TAG
        IXLOC=IX_TO_TAG(I);
        
        [LIST_TAGGED, TAGGED, EVERTAGGED, NUM_EVERTAGGED, EVERTAGGED_IX] =...
        TAG_BAND(NX, IXLOC, T, LIST_TAGGED, TAGGED, EVERTAGGED, NUM_EVERTAGGED,...
                    EVERTAGGED_IX, BANDTHICKNESS, FuelMap, M1, M10, M100, MLH, MLW, U_wind, WAF);
    end
    
    % Memorize number of embers recieved by each cell
%     for I = 1:N_SPOT_FIRES
%         IX = IX_SPOT_FIRE(I);
%         TIME_DIFF=abs(T-TIME_TO_IGNITE(I));
%         if (TIME_DIFF<=DT/2)
%             EMBER_FLUX_HIST(IX)=EMBER_FLUX_HIST(IX)+1;
%         end
%     end

    if(~EMBER_TRAVEL_BY_WIND)
%--------------------------ELMFIRE_MAT1D_0.1.7, Non-flying time-----------------------------%
        PHIP(SPOT_IGNITION==1)     = -1.0;
        PHIP_OLD(SPOT_IGNITION==1) = -1.0;
        for I = 1:N_SPOT_FIRES
            IX = IX_SPOT_FIRE(I);

            if (IX)
                % Ember ignition time correction
                if (SURFACE_FIRE(IX) <= 0)
                    IXLOC = IX;

                    [LIST_TAGGED, TAGGED, EVERTAGGED, NUM_EVERTAGGED, EVERTAGGED_IX] =...
                        TAG_BAND(NX, IXLOC, T, LIST_TAGGED, TAGGED, EVERTAGGED, NUM_EVERTAGGED,...
                            EVERTAGGED_IX, BANDTHICKNESS, FuelMap, M1, M10, M100, MLH, MLW, U_wind, WAF);

%                     TIME_OF_ARRIVAL(IX) = T;
%                     SURFACE_FIRE(IX)    = 1;
                    SPOT_IGNITION(IX)   = 1;
                    if(PHIP_OLD(IX)>0 )
                        PHIP(IX)            = -1;
                        PHIP_OLD(IX)        = -1;
                    end
                end
            end
        end

%--------------------------END OF ELMFIRE_MAT1D_0.1.7-----------------------------%
    else
%--------------------------BEGIN OF ELMFIRE_MAT1D_0.1.8 Flytime Counted---------------------------%
        PHIP(SPOT_IGNITION==1)     = -1.0;
        PHIP_OLD(SPOT_IGNITION==1) = -1.0;

        for IX = 1: length(PHIP)
            % Ember ignition time correction
            if (SURFACE_FIRE(IX) <= 0)
                TIME_DIFF=T+DT-TIME_TO_IGNITE(IX);
                if (TIME_DIFF>=0 && PHIP_OLD(IX)>0)
                    [LIST_TAGGED, TAGGED, EVERTAGGED, NUM_EVERTAGGED, EVERTAGGED_IX] =...
                        TAG_BAND(NX, IX, T, LIST_TAGGED, TAGGED, EVERTAGGED, NUM_EVERTAGGED,...
                            EVERTAGGED_IX, BANDTHICKNESS, FuelMap, M1, M10, M100, MLH, MLW, U_wind, WAF);
%                     TIME_OF_ARRIVAL(IX) = T;
%                     SURFACE_FIRE(IX)    = 1;
                    SPOT_IGNITION(IX)   = 1;
                    PHIP(IX)            = -1;
                    PHIP_OLD(IX)        = -1;
%                     dlmwrite(sprintf('TIME_DIFF_DX%.1f_DT%.1f.csv',delX,delT),TIME_DIFF,'-append')
                
                    
%                     if(~exist(sprintf('SOURCE_DX%.1f_DT%.1f.bin',delX,delT),'file'))
%                         FileID=fopen(sprintf('SOURCE_DX%.1f_DT%.1f.bin',delX,delT),'w');
%                     else
%                         FileID=fopen(sprintf('SOURCE_DX%.1f_DT%.1f.bin',delX,delT),'a');
%                     end
%                     fwrite(FileID,SOURCE);
%                     fclose(FileID);
%                     dlmwrite('DELAY_TIME_DIAG_1.csv',TIME_TO_IGNITE)
                end
            end
        end
%--------------------------END OF ELMFIRE_MAT1D_0.1.8------------------------------%   
    end
%  
%     if(mod(ITIMESTEP,UNTAG_CELLS_TIMESTEP_INTERVAL) == 0 && length(LIST_TAGGED) > 100)
%         UNTAG_CELLS(NX,NY,TIME_OF_ARRIVAL,T,SURFACE_FIRE,DT)
%     end

    % Diagnose the transposrt distance of all effective embers, which
    % ignite new fire spots.
    if(~exist([RES_DIR,'/SOURCE.bin'],'file'))
        FileID=fopen([RES_DIR,'/SOURCE.bin'],'w');
    else
        FileID=fopen([RES_DIR,'/SOURCE.bin'],'a');
    end
    fwrite(FileID,SOURCE);
    fclose(FileID);

    if(max(PHIP)<0)
        break
    end
    
%--------------------phi noise perturbation----------------------%
%     NOISE=rand(size(PHIP))*0.001;
%     PHIP=PHIP+NOISE;
%--------------------phi noise perturbation----------------------%
end

end
