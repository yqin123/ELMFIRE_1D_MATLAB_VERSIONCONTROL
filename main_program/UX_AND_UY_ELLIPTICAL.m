function C = UX_AND_UY_ELLIPTICAL(L,ISTEP,SURFACE_FIRE, FUEL_MODEL_TABLE_2D, ...
                                  PHIW_ADJ, LOW_FROM_WSMFEFF, BOH_FROM_LOW,...
                                  U_wind, a_0, d, f_b)

KWPM2_TO_BTUPFT2MIN = 60. * 0.3048 * 0.3048 / 1.055;
FTPMIN_TO_MPS = 0.3048 / 60.;

C = L;

if (ISTEP == 1) 
    for I = 1: length(C)

        IX = C(I).IX;

        if (SURFACE_FIRE(IX) == 0) 
            C(I).PHISX = 0.0;
            if (C(I).FLIN_SURFACE >= C(I).CRITICAL_FLIN) 
                APHIW = PHIW_ADJ * max(C(I).PHIW_SURFACE, C(I).PHIW_CROWN);
            else
                APHIW = PHIW_ADJ * C(I).PHIW_SURFACE;
            end

            if(C(I).IFBFM == 91) 
                % CONSIDER SLOPE HAS NO EFFET IN THE URBAN REGION
                APHIW = 1.0;
                
            end
            % Hit lookup table for trig functions
            PHIWX = APHIW;
            PHIX  = C(I).PHISX + PHIWX;

            PHIMAG = max(abs(PHIX),1E-20);
            RPHIMAG = 1. / PHIMAG;

            C(I).NORMVECTORX_DMS = RPHIMAG * PHIX;
            C(I).VELOCITY_DMS = C(I).VS0 * (1+PHIMAG);
            
            FMT=FUEL_MODEL_TABLE_2D(C(I).IFBFM,30);
            FMT=cell2mat(FMT);
            
            WSMFEFF = FMT.WSMFEFF_COEFF * PHIMAG ^ FMT.B_COEFF_INVERSE;

            if (C(I).FLIN_SURFACE < C(I).CRITICAL_FLIN) 
                WSMFEFF = min(WSMFEFF, 0.9*KWPM2_TO_BTUPFT2MIN*C(I).IR);
            end

            IWSMFEFF = min( max ( round(10.0*WSMFEFF)+1, 1), 100001);
            C(I).LOW = LOW_FROM_WSMFEFF(IWSMFEFF);

            ILOW = min(max(round(1000. * C(I).LOW)+1,1),20001);
            BOH = BOH_FROM_LOW (ILOW);
            C(I).VBACK = BOH * C(I).VELOCITY_DMS;

            if (C(I).IFBFM == 91)
                C(I) = HAMADA(C(I), U_wind, a_0, d, f_b); % GET C%VELOCITY_DMS, C%VBACK & C%LOW
            end
%             fprintf("%.1f,%.1f \n",C(I).NORMVECTORX,C(I).NORMVECTORX_DMS);
            SIGN = C(I).NORMVECTORX * C(I).NORMVECTORX_DMS;
            A        = max(0.5 * (C(I).VELOCITY_DMS + C(I).VBACK), 1E-10);
            DXDT     = A*SIGN + 0.5 * (C(I).VELOCITY_DMS - C(I).VBACK);
            if (abs(SIGN)<0.05)
                DXDT = C(I).VELOCITY_DMS + C(I).VBACK;
            end
            C(I).UX = DXDT * FTPMIN_TO_MPS; %Convert ft/min to m/s
        end

    end

else %ISTEP == 2

    for I = 1: length(C)

        IX = C(I).IX;

        if (SURFACE_FIRE(IX) == 0) 
            SIGN = C(I).NORMVECTORX * C(I).NORMVECTORX_DMS;
            A        = max(0.5 * (C(I).VELOCITY_DMS + C(I).VBACK), 1E-10);
            DXDT     = A * SIGN + 0.5 * (C(I).VELOCITY_DMS - C(I).VBACK);
            if (abs(SIGN)<0.05)
                DXDT = C(I).VELOCITY_DMS + C(I).VBACK;
            end
            C(I).UX = DXDT * FTPMIN_TO_MPS; %Convert ft/min to m/s

            ILH = max(min(round(100.*C(I).MLH),120),30);
            C(I).VELOCITY = sqrt(DXDT*DXDT); % ft/min
            
            FMT=FUEL_MODEL_TABLE_2D(C(I).IFBFM,ILH);
            FMT=cell2mat(FMT);
            
            C(I).FLIN_SURFACE = FMT.TR * C(I).IR * C(I).VELOCITY * 0.3048; % kW/m
            
            if(C(I).IFBFM == 91)
                C(I).FLIN_SURFACE = 10;
            end
        end
   end
end %ISTEP == 1