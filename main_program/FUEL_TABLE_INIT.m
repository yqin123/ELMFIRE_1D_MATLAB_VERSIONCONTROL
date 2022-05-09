%Fuel table struct
TABLE=readtable('FBFM_LABELED.csv');
[TOTNUM, PARANUM]=size(TABLE);
for i=1:TOTNUM
    INUM = TABLE(i,:).INUM;
    FM.SHORTNAME= TABLE(i,:).SHORTNAME;
    if(strcmp(TABLE(i,:).DYNAMIC, '.FALSE.'))
        FM.DYNAMIC=false;
    else
        FM.DYNAMIC=true;
    end
    FM.W0(1)=TABLE(i,:).W0_1_;
    FM.W0(2)=TABLE(i,:).W0_2_;
    FM.W0(3)=TABLE(i,:).W0_3_;
    FM.W0(5)=TABLE(i,:).W0_5_;
    FM.W0(6)=TABLE(i,:).W0_6_;
    FM.SIG(1)=TABLE(i,:).SIG_1_;
    FM.SIG(5)=TABLE(i,:).SIG_5_;
    FM.SIG(6)=TABLE(i,:).SIG_6_;
    FM.DELTA=TABLE(i,:).DELTA;
    FM.MEX_DEAD=TABLE(i,:).MEX_DEAD;
    FM.HOC=TABLE(i,:).HOC;
    FM.TAU=TABLE(i,:).RES_TIME;

    FM.MEX_DEAD = FM.MEX_DEAD ./ 100.;
    FM.SIG(2) = 109.;  %  10-hour surface area to volume ratio, 1./ft
    FM.SIG(3) = 30.;  % 100-hour surface area to volume ratio, 1./ft
    FM.RHOP   = 32.; % Particle density
    FM.ST     = 0.055;
    FM.SE     = 0.01;
    FM.ETAS   = 0.174./(FM.SE.^0.19); %mineral damping coefficient, dimensionless

    FUEL_MODEL_TABLE(INUM) = FM;
end

FUEL_MODEL_TABLE_2D=num2cell(zeros([1 120]));

for INUM = 1:256
   if (isempty(FUEL_MODEL_TABLE(INUM).SHORTNAME))
       continue
   end
   
   FUEL_MODEL_TABLE_2D(INUM,:) = repmat({FUEL_MODEL_TABLE(INUM)},[1 120]);

   for ILH = 30:120
      LH = double(ILH);
      FM = cell2mat(FUEL_MODEL_TABLE_2D(INUM,ILH));

      if (FM.DYNAMIC)
         LIVEFRAC  = min( max( (LH - 30. ) ./ (120.  - 30. ) , 0.), 1.);
         DEADFRAC  = 1. - LIVEFRAC;
         FM.W0 (4) = DEADFRAC .* FM.W0(5);
         FM.W0 (5) = LIVEFRAC .* FM.W0(5);
         FM.SIG(4) = FM.SIG(5);
         FM.SIG(1) = (FM.SIG(1).*FM.SIG(1).*FM.W0(1) + FM.SIG(4).*FM.SIG(4).*FM.W0(4)) ./...
                    ( FM.SIG(1).*FM.W0(1) + FM.SIG(4).*FM.W0(4) );
         FM.W0 (1) = FM.W0(1) + FM.W0(4);
         FM.W0 (4) = 0.;
         FM.SIG(4) = 9999.;
      else
         FM.W0 (4) = 0.0;
         FM.SIG(4) = 9999.;
      end
   
      FM.A(:) = FM.SIG(:).*FM.W0(:) ./ FM.RHOP;

      FM.A_DEAD = max(sum(FM.A(1:4)),1E-9);
      FM.A_LIVE = max(sum(FM.A(5:6)),1E-9);
      FM.A_OVERALL = FM.A_DEAD + FM.A_LIVE;

      FM.F   (1:4) = FM.A(1:4) ./ FM.A_DEAD;
      FM.FMEX(1:4) = FM.F(1:4) .* FM.MEX_DEAD;
      FM.F   (5:6) = FM.A(5:6) ./ FM.A_LIVE;
   
      FM.F_DEAD = FM.A_DEAD ./ FM.A_OVERALL;
      FM.F_LIVE = FM.A_LIVE ./ FM.A_OVERALL;

      FM.FW0(:) = FM.F(:) .* FM.W0(:);
   
      FM.FSIG(:) = FM.F(:) .* FM.SIG(:);

      FM.EPS(:) = exp(-138. ./ FM.SIG(:));

      FM.FEPS(:) = FM.F(:) .* FM.EPS(:);

      FM.WPRIMENUMER(1:4) = FM.W0(1:4) .* FM.EPS(1:4);
      FM.WPRIMEDENOM(5:6) = FM.W0(5:6) .* exp(-500../FM.SIG(5:6));

      FM.MPRIMEDENOM(1:4) = FM.W0(1:4) .* FM.EPS(1:4);
   
      FM.W0_DEAD = sum(FM.FW0(1:4));
      FM.W0_LIVE = sum(FM.FW0(5:6));
   
      FM.WN_DEAD = FM.W0_DEAD .* (1. - FM.ST);
      FM.WN_LIVE = FM.W0_LIVE .* (1. - FM.ST);
      
      FM.SIG_DEAD = sum(FM.FSIG(1:4));
      FM.SIG_LIVE = sum(FM.FSIG(5:6));
  
      FM.SIG_OVERALL = FM.F_DEAD .* FM.SIG_DEAD + FM.F_LIVE .* FM.SIG_LIVE;
      FM.BETA        = sum(FM.W0(1:6)) ./ (FM.DELTA .* FM.RHOP);
      FM.BETAOP      = 3.348./(FM.SIG_OVERALL.^0.8189);
      FM.RHOB        = sum(FM.W0(1:6)) ./ FM.DELTA;
   
      FM.XI = exp((0.792 + 0.681.*sqrt(FM.SIG_OVERALL)).*(0.1+FM.BETA)) ./ (192. + 0.2595.*FM.SIG_OVERALL);
   
      FM.A_COEFF = 133../(FM.SIG_OVERALL.^0.7913);
      FM.B_COEFF = 0.02526.*FM.SIG_OVERALL.^0.54;
      FM.C_COEFF = 7.47.*exp(-0.133.*FM.SIG_OVERALL.^0.55);
      FM.E_COEFF = 0.715.*(exp(-0.000359.*FM.SIG_OVERALL));
   
      FM.GAMMAPRIMEPEAK = FM.SIG_OVERALL.^1.5 ./ (495. + 0.0594.*FM.SIG_OVERALL.^1.5);
      FM.GAMMAPRIME = FM.GAMMAPRIMEPEAK.*(FM.BETA./FM.BETAOP).^FM.A_COEFF.*exp(FM.A_COEFF.*(1.-FM.BETA./FM.BETAOP));
   
      FM.TR = 384. ./ FM.SIG_OVERALL; %Residence time, min

      FM.GP_WND_EMD_ES_HOC = FM.GAMMAPRIME .* FM.WN_DEAD .* FM.ETAS .* FM.HOC;
      FM.GP_WNL_EML_ES_HOC = FM.GAMMAPRIME .* FM.WN_LIVE .* FM.ETAS .* FM.HOC;

      FM.PHISTERM=5.275 .* FM.BETA.^(-0.3);
      FM.PHIWTERM = FM.C_COEFF .* (FM.BETA ./ FM.BETAOP).^(-FM.E_COEFF);

      FM.B_COEFF_INVERSE = 1. ./ FM.B_COEFF;
      FM.WSMFEFF_COEFF = (1. ./ FM.PHIWTERM) .^ FM.B_COEFF_INVERSE;

      FM.WPRIMEDENOM56SUM = sum(FM.WPRIMEDENOM(5:6));
      FM.WPRIMENUMER14SUM = sum(FM.WPRIMENUMER(1:4));
      FM.MPRIMEDENOM14SUM = sum(FM.MPRIMEDENOM(1:4));

      FM.R_MPRIMEDENOME14SUM_MEX_DEAD = 1. ./ (FM.MPRIMEDENOM14SUM .* FM.MEX_DEAD);

      FM.UNSHELTERED_WAF = CALC_WIND_ADJUSTMENT_FACTOR_SINGLE(0., 0., FM.DELTA);

      if (FM.WPRIMEDENOM56SUM > 1E-6) 
         FM.MEX_LIVE = 2.9 .* FM.WPRIMENUMER14SUM ./ FM.WPRIMEDENOM56SUM;
      else
         FM.MEX_LIVE = 100.0;
      end

      FUEL_MODEL_TABLE_2D(INUM,ILH) = {FM};

   end

end
%Set any unused fuel models to 256 (NB)
for INUM = 1:256
    for ILH = 1:120
        NAME = cell2mat(FUEL_MODEL_TABLE_2D(INUM,ILH));
        if (isempty(NAME))
            FUEL_MODEL_TABLE_2D(INUM,ILH) = FUEL_MODEL_TABLE_2D(256,ILH);
        end
    end
end

% % Build lookup tables:
% if (.NOT. ALLOCATED(LOW_FROM_WSMFEFF))  
%    ALLOCATE(LOW_FROM_WSMFEFF(0:100000))
%    ALLOCATE(BOH_FROM_LOW    (0:20000))
%    ALLOCATE(WSMFEFF_FROM_FBFM_AND_PHIMAG(0:256,0:10000))
% 
%    LOW_FROM_WSMFEFF(0) = 1E0
%    DO I = 1, 100000
%       WSMFEFF=REAL(I) .* 0.1
%       LOW_FROM_WSMFEFF(I)=min( 0.936.*exp(0.2566.*WSMFEFF.*60../5280.) + 0.461.*exp(-0.1548.*WSMFEFF.*60.0./5280.) - 0.397, max_LOW)
%    ENDDO
% 
%    BOH_FROM_LOW(0:1000) = 1.
%    DO I = 1001, 20000
%       LOW = REAL(I) .* 0.001
%       BOH_FROM_LOW(I)= 1.0 ./ ((LOW + SQRT(LOW.*LOW - 1.0)) ./ (LOW - SQRT(LOW.*LOW -1.0)))
%    ENDDO
% 
%    DO INUM = 0, 256
%       if (FUEL_MODEL_TABLE_2D(INUM,30).B_COEFF_INVERSE .GT. 1E-3) 
%          DO I = 0, 10000
%             PHIMAG = REAL(I) .* 0.01
%             WSMFEFF_FROM_FBFM_AND_PHIMAG(INUM,I) = FUEL_MODEL_TABLE_2D(INUM,30).WSMFEFF_COEFF .* PHIMAG .*.* FUEL_MODEL_TABLE_2D(INUM,30).B_COEFF_INVERSE
%          ENDDO
%       end
%    ENDDO
% 
%    DO I = 1, 256
%       WSMFEFF_COEFF  (I) = FUEL_MODEL_TABLE_2D(I,30).WSMFEFF_COEFF
%       B_COEFF_INVERSE(I) = FUEL_MODEL_TABLE_2D(I,30).B_COEFF_INVERSE
%       TR             (I) = FUEL_MODEL_TABLE_2D(I,30).TR
%    ENDDO   
% 
% end