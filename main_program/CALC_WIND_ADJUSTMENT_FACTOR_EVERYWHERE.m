function WAF=CALC_WIND_ADJUSTMENT_FACTOR_EVERYWHERE(CC, CH, FBFM, FUEL_MODEL_TABLE_2D, NX)
WAF = zeros(size(CC));
SHELTERED_WAF_TABLE = zeros([100, 120]);
for ICC = 1:100
   CC1=ICC*0.01;
   for ICH = 1:120
      CH1 = ICH;
      SHELTERED_WAF_TABLE(ICC,ICH) = CALC_WIND_ADJUSTMENT_FACTOR_SINGLE(CC1, CH1, 0.);
   end
end

for ICOL = 1:NX
    if(CC(ICOL) < 0.)
        WAF(ICOL) = 0.;
    else
        if (CC(ICOL) > 1E-4 && CH(ICOL) > 1E-4)
            ICC=min(max(round(CC(ICOL)*100.),0),100);
            ICH=min(max(round(CH(ICOL)     ),0),120);
            WAF(ICOL)=SHELTERED_WAF_TABLE(ICC,ICH);
        else %Canopy is not present
            FMT = cell2mat(FUEL_MODEL_TABLE_2D(max(FBFM(ICOL),1),30));
            WAF(ICOL) = FMT.UNSHELTERED_WAF;
        end
    end
end

end