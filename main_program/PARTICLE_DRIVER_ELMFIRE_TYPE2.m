function [N_SPOT_FIRES, IX_SPOT_FIRE, TIME_TO_IGNITE, EMBER_FLUX, EMBER_SOURCE]=...
    PARTICLE_DRIVER_ELMFIRE_TYPE2(...
   T_ELMFIRE                 , ...
   NX                        , ...
   XLLCORNER                 , ...
   delX                      , ...
   NUM_EMBERS_PER_TORCH_ELM  , ...
   X0_ELM                    , ... 
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
   ERR)  

% Definition of X_max changed to statistical definition, PDF(k_max)<1e-3
% Test inputs: 
% delX=0.5;ERR = 1e-3;MU_DIST=2.18;SIGMA_DIST=1.23;
pdf=@(x)1./(x*SIGMA_DIST*sqrt(2*pi)).*exp(-(log(x)-MU_DIST).^2/SIGMA_DIST^2/2);
k_max = 0;
PDF_k = 1;
while(PDF_k>ERR)
    k_max = k_max+1;
    PDF_k = integral(@(x)(x>=0).*pdf(x),(k_max-1/2)*delX,(k_max+1/2)*delX)/delX;
end
X_MAX = k_max*delX;
% -------- End of Definition of X_max change

X0 = X0_ELM;
TSTOP  =  TSTOP_SPOT;              % Stop time 
UWIND = U_wind*0.447; % m/s

for IEMBER = 1: NUM_EMBERS_PER_TORCH_ELM

    % Get spotting distance
    R0=rand(1);
    if (SPOTTING_DISTRIBUTION_TYPE == 0) %uniform
        SPOTTING_DISTANCE = MIN_SPOTTING_DISTANCE + R0 * (MAX_SPOTTING_DISTANCE - MIN_SPOTTING_DISTANCE);
    elseif(SPOTTING_DISTRIBUTION_TYPE == 3) %Trunced normal;
        SPOTTING_DISTANCE = 100;

    else
%         if (R0 >= 0.5)
%             SPOTTING_DISTANCE = exp(sqrt(2.) * SIGMA_DIST * erfinv(2.*R0-1.) + MU_DIST);
%         else
%             SPOTTING_DISTANCE = exp(MU_DIST - sqrt(2.) * SIGMA_DIST * erfinv(1.-2.*R0));
%         end 
        Fx=@(x)1/2*(1+erf((log(x)-MU_DIST)/sqrt(2)/SIGMA_DIST));
        Low = Fx(delX/2);High=Fx(X_MAX);
        R0 = R0*(High-Low)+Low;
        SPOTTING_DISTANCE = exp(sqrt(2.) * SIGMA_DIST * erfinv(2.*R0-1.) + MU_DIST);
    end

    DIST = 0.;

    OFFSET = X0;
    X  = X0 - OFFSET;
    T_ember = T_ELMFIRE;

    IXLAST = 0;

    DT_ember = min ( 0.5 * delX / max (U_wind, 0.01), 5.0);

    while(T_ember <= TSTOP && DIST <= SPOTTING_DISTANCE )
        T_ember = T_ember + DT_ember;
        IX = ceil((X + OFFSET - XLLCORNER) / delX)+2;

        if (IX ~= IXLAST)
            if (IX >= NX-2 || IX <= 3)
                T_ember = 9E9; continue
            end
            DT_ember = min ( 0.5 * delX / max (U_wind, 0.01), 5.0);
        end

        if (abs(UWIND) <= 1E-6) 
            T_ember=9E9;
        end

        X = X + UWIND * DT_ember;
        DIST     = DIST + UWIND * DT_ember;

        IXLAST = IX;
    end

    if (T_ember < 1E9) 
        IX = ceil((X + OFFSET - XLLCORNER) / delX)+2 ; IX = max(IX,3) ; IX = min (IX,NX-2);

        EMBER_FLUX(IX) = EMBER_FLUX(IX) + 1;

        IGNPROB=0.01*PIGN;
        
%         if(DIAG_PDF)
% %             EMBER_TARGET = [EMBER_TARGET,X + OFFSET - XLLCORNER];
%             EMBER_SOURCE = [EMBER_SOURCE,X0];
%         end
        
        R0=rand();

%         if (IGNPROB > R0 && DIST > 1.5*delX)
        if (IGNPROB > R0)
            GO = true;
            I1 = max(IX-3,3   );
            I2 = min(IX+3,NX-2);

            for I = I1:I2
                if (PHIP(I) < 0.) 
                    GO = false;
                end
            end
            
%             if (PHIP(IX) < 0.) 
%                 GO = false;
%             end
            
            if (GO)
                N_SPOT_FIRES = N_SPOT_FIRES + 1;
                IX_SPOT_FIRE(N_SPOT_FIRES) = IX;
%                 TIME_TO_IGNITE(N_SPOT_FIRES) = SPOTTING_DISTANCE/UWIND;
                if(TIME_TO_IGNITE(IX)>=9999)
                    TIME_TO_IGNITE(IX) = T_ember;
                end
                if(DIAG_PDF)
                    EMBER_SOURCE = [EMBER_SOURCE,X0];
                end
            end
        end
    end
end