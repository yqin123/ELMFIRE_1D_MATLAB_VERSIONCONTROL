function CALC_WIND_ADJUSTMENT_FACTOR=CALC_WIND_ADJUSTMENT_FACTOR_SINGLE(CC, CH, FUEL_BED_HEIGHT)

if (CC < 0.) 
   CALC_WIND_ADJUSTMENT_FACTOR = 0.;
else
    if (CC > 1E-4 && CH > 1E-4)  %Canopy is present
        HFT = CH / 0.3048 ;
        NUMER = 20. + 0.36*HFT;
        DENOM = 0.13 * HFT;
        UHOU20PH = 1. / log(NUMER/DENOM);
        F = CC / 3. ;%Same as BEHAVE
        UCOUH = 0.555 / sqrt(F * HFT);
        CALC_WIND_ADJUSTMENT_FACTOR = UHOU20PH * UCOUH;
    else %Canopy is not present
        if (FUEL_BED_HEIGHT > 1E-4) 
            HFOH = 1.0; % Same as BEHAVE and FARSITE
            HFT = FUEL_BED_HEIGHT;
            NUMER = 20. + 0.36*HFT;
            DENOM = 0.13 * HFT;
            TERM1 = (1. + 0.36/HFOH) / log(NUMER/DENOM);
            NUMER = HFOH + 0.36;
            TERM2 = log(NUMER/0.13) - 1.;
            CALC_WIND_ADJUSTMENT_FACTOR = TERM1 * TERM2     ;  
        else
            CALC_WIND_ADJUSTMENT_FACTOR = 0.;
        end
    end
end

end