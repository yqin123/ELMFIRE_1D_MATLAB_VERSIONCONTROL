function C = SURFACE_SPREAD_RATE(L, FUEL_MODEL_TABLE_2D)
% Applies Rothermel suface fire spread model to calculate surface fire rate
% of spread, heat per unit area, fireline intensity, flame length, and 
% reaction intensity
PERTURB_ADJ = 0;
BTUPFT2MIN_TO_KWPM2 = 1.055/(60. * 0.3048 * 0.3048);

C=L;
for I = 1: length(L)
      
   M(1)  = C(I).M1;
   M(2)  = C(I).M10;
   M(3)  = C(I).M100;
   M(4)  = C(I).M1; %Set dynamic dead to m1
   M(5)  = C(I).MLH;
   M(6)  = C(I).MLW;

   ILH = max(min(round(100.*M(5)),120),30);
   FMT=FUEL_MODEL_TABLE_2D(C(I).IFBFM,ILH);
   FMT=cell2mat(FMT);
%Calculate live fuel moisture of extinction:
   MPRIMENUMER(1:4) = FMT.WPRIMENUMER(1:4) .* M(1:4);
   SUM_MPRIMENUMER=sum(MPRIMENUMER(1:4));
   MEX_LIVE = FMT.MEX_LIVE * (1. - FMT.R_MPRIMEDENOME14SUM_MEX_DEAD * SUM_MPRIMENUMER ) - 0.226;

   MEX_LIVE = max(MEX_LIVE, FMT.MEX_DEAD);
   FMEX(5:6) = FMT.F(5:6) .* MEX_LIVE;

   FMEX(1:4) = FMT.FMEX(1:4);

   FMC = FMT.F .* M;

   QIG = 250. + 1116.*M;

   FEPSQIG = FMT.FEPS .* QIG;

   RHOBEPSQIG_DEAD = FMT.RHOB * sum(FEPSQIG(1:4));
   RHOBEPSQIG_LIVE = FMT.RHOB * sum(FEPSQIG(5:6));
   RHOBEPSQIG = FMT.F_DEAD * RHOBEPSQIG_DEAD + FMT.F_LIVE * RHOBEPSQIG_LIVE;

   M_DEAD    = sum(FMC(1:4));
   MOMEX     = M_DEAD / FMT.MEX_DEAD;
   MOMEX2    = MOMEX * MOMEX;
   MOMEX3    = MOMEX2 * MOMEX;
   ETAM_DEAD = 1.0 - 2.59*MOMEX + 5.11*MOMEX2 - 3.52*MOMEX3;
   ETAM_DEAD = max(0.,min(ETAM_DEAD,1.));
   IR_DEAD   = FMT.GP_WND_EMD_ES_HOC * ETAM_DEAD;

   M_LIVE    = sum(FMC(5:6));
   MOMEX     = M_LIVE / MEX_LIVE;
   MOMEX2    = MOMEX * MOMEX;
   MOMEX3    = MOMEX2 * MOMEX;
   ETAM_LIVE = 1.0 - 2.59*MOMEX + 5.11*MOMEX2 - 3.52*MOMEX3;
   ETAM_LIVE = max(0.,min(ETAM_LIVE,1.));
   IR_LIVE   = FMT.GP_WNL_EML_ES_HOC * ETAM_LIVE;

   C(I).IR = IR_DEAD + IR_LIVE; %Btu/(ft^2-min)

%  WS_LIMIT = 96.8*C%IR**0.3333333 !Andrews, Cruz, and Rothermel (2013) limit
   WS_LIMIT = 0.9*C(I).IR; %Original limit
   WSMF_LIMITED = min(C(I).WSMF, WS_LIMIT);

%   WRITE(*,*) 'WSMF_LIMITED', WSMF_LIMITED
   C(I).PHIW_SURFACE = FMT.PHIWTERM * WSMF_LIMITED^FMT.B_COEFF;

% max slope factor is equal to max wind factor:
   PHIS_MAX = FMT.PHIWTERM * WS_LIMIT^FMT.B_COEFF;
   C(I).PHIS_SURFACE = min(FMT.PHISTERM * C(I).TANSLP2, PHIS_MAX);

   C(I).VS0 = (C(I).ADJ + PERTURB_ADJ) * C(I).SUPPRESSION_ADJUSTMENT_FACTOR * C(I).IR * FMT.XI / RHOBEPSQIG; %ft/min

% Convert reaction intensity to SI:
   C(I).IR           = C(I).IR * BTUPFT2MIN_TO_KWPM2; % kW/m2
   C(I).HPUA_SURFACE = FMT.TR * 60.; % kJ/m2

end


end