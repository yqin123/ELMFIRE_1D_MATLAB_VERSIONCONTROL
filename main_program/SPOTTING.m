function [N_SPOT_FIRES, IX_SPOT_FIRE, TIME_TO_IGNITE, EMBER_FLUX, EMBER_SOURCE]=....
    SPOTTING(T_ELMFIRE, IX,U_wind,FLIN,N_SPOT_FIRES, ...
               SPOTTING_DISTRIBUTION_TYPE, ...
               NEMBERS_MIN,NEMBERS_MAX,NX,XLLCORNER, delX,TSTOP_SPOT, ...
               PIGN, PHIP, MIN_SPOTTING_DISTANCE, MAX_SPOTTING_DISTANCE,...
               EMBER_FLUX,IX_SPOT_FIRE, TIME_TO_IGNITE, EMBER_SOURCE, DIAG_PDF, ERR)
% Initial position vector
X0 = (IX-0.5) * delX;

[MU_DIST,SIGMA_DIST]=MODELPARAMETER(SPOTTING_DISTRIBUTION_TYPE, FLIN, U_wind);

R0=rand(1);
NEMBERS = NEMBERS_MIN + round (R0 * (NEMBERS_MAX - NEMBERS_MIN) );
[N_SPOT_FIRES, IX_SPOT_FIRE, TIME_TO_IGNITE, EMBER_FLUX, EMBER_SOURCE]=...
    PARTICLE_DRIVER_ELMFIRE_TYPE2(...
        T_ELMFIRE                 , ...
        NX                        , ...
        XLLCORNER                 , ...
        delX                      , ...
        NEMBERS                   , ...
        X0                        , ... 
        TSTOP_SPOT                , ... 
        PIGN                      , ...
        PHIP                      , ...
        MIN_SPOTTING_DISTANCE     , ...
        MAX_SPOTTING_DISTANCE     , ...
        SIGMA_DIST                , ...
        MU_DIST                   , ...
        SPOTTING_DISTRIBUTION_TYPE, ...
        N_SPOT_FIRES              , ...
        EMBER_FLUX                , ...
        IX_SPOT_FIRE              , ...
        TIME_TO_IGNITE            , ...
        EMBER_SOURCE              , ...
        U_wind                    , ... 
        DIAG_PDF                  , ...
        ERR);
end