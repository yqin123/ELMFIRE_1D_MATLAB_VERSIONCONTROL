function [C,PHIP_OLD]=CALC_NORMAL_VECTORS(ISTEP, LIST_TAGGED,HALFRCELLSIZE, PHIP, PHIP_OLD)

EPSILON = 1E-30; BIG=3E4;

C = LIST_TAGGED;
if (ISTEP == 1)
    for I = 1:length(C)
        IX=C(I).IX;
        PHIP_OLD(IX) = PHIP(IX);
        DPHIDX = min( HALFRCELLSIZE * (PHIP(IX+1) - PHIP(IX-1)), BIG );
        RMAGGRADPHI = 1. / max(abs( DPHIDX), EPSILON);
        C(I).NORMVECTORX = RMAGGRADPHI * DPHIDX;
        if PHIP(IX+1)<0 && PHIP(IX-1)<0
            C(I).NORMVECTORX=1;
        end
    end
else
   for I = 1:length(C)
      IX=C(I).IX;
      DPHIDX = min( HALFRCELLSIZE * (PHIP(IX+1) - PHIP(IX-1)), BIG );
      RMAGGRADPHI = 1. / max(abs( DPHIDX ), EPSILON);
      C(I).NORMVECTORX = RMAGGRADPHI * DPHIDX;
      if PHIP(IX+1)<0 && PHIP(IX-1)<0
          C(I).NORMVECTORX=1;
      end
   end

end
end