
function PHIP=RK2_INTEGRATE(LIST_TAGGED,DT,ISTEP, PHIP, PHIP_OLD)

% 2nd order Runge Kutta integration:
C = LIST_TAGGED;
if (ISTEP == 1)
   for I = 1:length(LIST_TAGGED)
      PHIP(C(I).IX) = PHIP_OLD(C(I).IX) - DT * (C(I).UX * C(I).DPHIDX_LIMITED);
%       VALUE=PHIP(C(I).IX)
   end
else
    for I = 1:length(LIST_TAGGED)
      PHIP(C(I).IX) = 0.5 * (PHIP_OLD(C(I).IX) + (PHIP(C(I).IX) - DT * (C(I).UX * C(I).DPHIDX_LIMITED)));
%       VALUE=PHIP(C(I).IX)
    end
end

end
