function DT = CALC_CFL(LIST_TAGGED,DT,ANALYSIS_CELLSIZE,SIMULATION_DTMAX, FORCE_DT)

UMAX = 0.;
TARGET_CFL = 0.5;

for I = 1:length(LIST_TAGGED)
    U  = abs(LIST_TAGGED(I).UX);
    if (U > UMAX) 
        UMAX = U;
    end
end
CFL = UMAX * DT / ANALYSIS_CELLSIZE;
if (CFL > 0.)
    DT = min(TARGET_CFL * DT / CFL, SIMULATION_DTMAX);
else
    DT = SIMULATION_DTMAX;
end

if(FORCE_DT)
    DT = FORCE_DT;
end

end