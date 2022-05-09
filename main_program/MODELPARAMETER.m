function [MU_OUT,SIGMA_OUT]=MODELPARAMETER(SpotModel,FLIN,U_wind)
U_wind = U_wind*0.447; % m/s
FLIN   = FLIN*10^3;    % W/m
switch (SpotModel)
    case(1) % 1-ELMFIRE's Lognormal parameters
%         fprintf("ELMFIRE\n")
        MEAN_SPOTTING_DIST = 1;
        SPOT_FLIN_EXP      = 0.5;
        SPOT_WS_EXP        = 0.9;
        NORMALIZED_SPOTTING_DIST_VARIANCE = 100.0;
        MSD               = max( MEAN_SPOTTING_DIST*((FLIN/1000)^SPOT_FLIN_EXP)*(U_wind^SPOT_WS_EXP), 1.0);
        
        MU_DIST    = log(MSD*MSD / sqrt(MSD * NORMALIZED_SPOTTING_DIST_VARIANCE + MSD*MSD));
        SIGMA_DIST = sqrt(log(1. + MSD * NORMALIZED_SPOTTING_DIST_VARIANCE / (MSD*MSD))); 
        
        MU_OUT=MU_DIST;
        SIGMA_OUT=SIGMA_DIST;
%         fprintf("MU=%.2f,SIGMA=%.2f\n",MSD, NORMALIZED_SPOTTING_DIST_VARIANCE*MSD)
    case(2) % 2- Sardoy, 2008, Lognormal
%         fprintf("Sardoy\n")

        rho_inf = 1.1; % Air density, kg/m^2
        c_pg    = 1000; % Air heat capacity, J/kg-K
        T_inf   = 300;  % Ambient temperature, K
        g       = 9.81;  % Gravitional acceleration, m^2/s
        I = FLIN/1e6;
        Lc =(1e3*I/(rho_inf*c_pg*T_inf*g^(1/2)))^(2/3); % Character length scale
        Fr = U_wind/(g*Lc)^0.5;
        
        if (Fr<=1)
            MU_DIST=I^0.54*U_wind^(-0.55);
            MU_DIST=1.47*MU_DIST+1.14;
            SIGMA_DIST = I^(-0.21)*U_wind^(0.44);
            SIGMA_DIST = 0.86*SIGMA_DIST+0.19;
        else
            MU_DIST=I^0.26*U_wind^(0.11);
            MU_DIST=1.32*MU_DIST-0.02;
            SIGMA_DIST = I^(-0.01)*U_wind^(-0.02);
            SIGMA_DIST = 4.95*SIGMA_DIST-3.48;
        end
        
        MU_OUT=MU_DIST;
        SIGMA_OUT=SIGMA_DIST;
        
    case(3) % Himoto, 2005, Lognormal
% %         Verification case U_wind = 5m/s, Q=4.0kW, 
%         LogNormal = true;
%         rho_inf = 1.1;     % Air density, kg/m^2
%         rho_p   = 50;       % Particle density, kg/m^2
%         c_pg    = 1;        % Air heat capacity, kJ/kg-K
%         T_inf   = 300;      % Ambient temperature
%         g       = 9.81;      % Gravitional acceleration, m^2/s
%         D       = 0.08;        % Heat source length. m
%         d_p     = D/1000;    % Thickness of disk ember, m
%         Q       = 4.0;  % Heat release rate, kW
%         B_star = 5/sqrt(g*D)*(rho_p/rho_inf)^(-3/4)*...
%             (d_p/D)^(-3/4)*(Q/(rho_inf*c_pg*T_inf*g^0.5*D^2.5))^0.5;
%         
%         MU_X = 0.47 * B_star^(2/3) * D;
%         SIGMA_X = 0.88 * B_star^(1/3) * D;
%         MU_DIST    = log(MU_X / sqrt((SIGMA_X/MU_X)^2 + 1));
%         SIGMA_DIST = sqrt(log(1. + (SIGMA_X/MU_X)^2));   
% %         fprintf("MU=%.2f,SIGMA=%.2f\n",MU_DIST, SIGMA_DIST)

        rho_inf = 1.1;     % Air density, kg/m^2
        rho_p   = 100;       % Particle density, kg/m^2
        c_pg    = 1;        % Air heat capacity, kJ/kg-K
        T_inf   = 300;      % Ambient temperature
        g       = 9.81;      % Gravitional acceleration, m^2/s
        D       = 10;        % Heat source length. m
        d_p     = D/2000;    % Thickness of disk ember, m
        Q       = FLIN*D/1000;  % Heat release rate, kW
        B_star = U_wind/sqrt(g*D)*(rho_p/rho_inf)^(-3/4)*...
            (d_p/D)^(-3/4)*(Q/(rho_inf*c_pg*T_inf*g^0.5*D^2.5))^0.5;
        
        MU_X = 0.47 * B_star^(2/3) * D;
        SIGMA_X = 0.88 * B_star^(1/3) * D;
        MU_DIST    = log(MU_X / sqrt((SIGMA_X/MU_X)^2 + 1));
        SIGMA_DIST = sqrt(log(1. + (SIGMA_X/MU_X)^2));   
        MU_OUT=MU_DIST;
        SIGMA_OUT=SIGMA_DIST;
    case(4) % Himoto, 2021, TruncNormal
%         fprintf("Himoto, 2021\n") Verification case U=1.46 m/s Ejection
%         height 1.08m Vp/Ap=0.00593/0.0529
%         TruncNormal = true;
%         rho_inf     = 1.1; % Air density, kg/m^2
%         rho_p       = 60.6;   % Particle density, kg/m^2
%         g           = 9.8;  % Gravitional acceleration, m^2/s
%         d_p         = 0.03/0.1;  % representative length of ember, cm
%         a = 4.34; b = 0.48; c = 1.21; d = 1.15;
%         H           = 1.08;    % Releasing height, m
%         W0          = 3.2;
%         B_star      = (U_wind*W0/(g*(d_p*H)^0.5))^2*(rho_inf/rho_p)*...
%                       (1+sqrt(1+sqrt(1+2*g*H/W0^2)))^2;
%         
%         MU = a*B_star*H + b;
%         SIGMA = c*B_star*H + d;
%         TruncNormal = true;
%         rho_inf     = 1.1; % Air density, kg/m^2
%         rho_p       = 60.6;   % Particle density, kg/m^2
%         c_pg        = 1000; % Air heat capacity, J/kg-K
%         T_inf       = 300;  % Ambient temperature
%         g           = 9.8;  % Gravitional acceleration, m^2/s
%         D           = 0.6; % Heat source length. m
%         d_p         = 0.03/0.1;  % representative length of ember, cm
%         a = 4.34; b = 0.48; c = 1.21; d = 1.15;
%         H           = 1.08;    % Releasing height, m
%         Q           = 330.14;  % Heat release rate, kW
%         Qc          = 0.6*Q; % to adjust
%         z0          = -1.02*D + 0.083*Q^(2/5); % to adjust
%         W0          = 3.4*(g/(c_pg*rho_inf*T_inf))^(1/3)*Qc^(1/3)*(max(H,2*z0)-z0)^(-1/3);% Initial vertical verlocity, m/s
%         B_star      = (U_wind*W0/(g*(d_p*H)^0.5))^2*(rho_inf/rho_p)*...
%                       (1+sqrt(1+sqrt(1+2*g*H/W0^2)))^2;
%         
%         MU = a*B_star*H + b;
%         SIGMA = c*B_star*H + d;

        rho_inf     = 1.1; % Air density, kg/m^2
        rho_p       = 100;   % Particle density, kg/m^2
        c_pg        = 1000; % Air heat capacity, J/kg-K
        T_inf       = 300;  % Ambient temperature
        g           = 9.8;  % Gravitional acceleration, m^2/s
        D           = 10; % Heat source length. m
        d_p         = 10/2000*100;  % representative length of ember, cm
        a = 4.34; b = 0.48; c = 1.21; d = 1.15;
        H           = 1.08;    % Releasing height, m
        Q           = FLIN/1000*10;  % Heat release rate, kW
        Qc          = 0.6*Q;
        z0          = -1.02*D + 0.083*Q^(2/5);
        W0          = 3.4*(g/(c_pg*rho_inf*T_inf))^(1/3)*Qc^(1/3)*(max(H,z0+1)-z0)^(-1/3); % Initial vertical verlocity, m/s
%         W0          = 3.2;
        B_star      = (U_wind*W0/(g*(d_p*H)^0.5))^2*(rho_inf/rho_p)*...
                      (1+sqrt(1+sqrt(1+2*g*H/W0^2)))^2;
        
        MU = a*B_star*H + b;
        SIGMA = c*B_star*H + d;
        MU_OUT=MU;
        SIGMA_OUT=SIGMA;
    case(5) % Kaur, 2016, Lognormal
%         fprintf("Kaur\n") Validation case Uind=4.47m/s FLIN= 20 MW/m
        rho_inf = 1.1;             % air density, kg/m^3
        rho_f   = 100;              % wild-land fuel density
        C_d     = 1;             % Drag coefficient
        g       = 9.81;              % Gravational acceleration, m/s^2
        r        = 0.05;             % Firebrand radius, m
        beta0   = 0.026;            % Byram-7.75e-2, Clark-7.22e-4, Wilgen-7.5e-3, Fons-0.127, Anderson-0.0447, Wang-0.026445, Bulter-0.0175
        beta1   = 2/3;              % Byram-0.46,    Clark-0.99,    Wilgen-0.46,   Fons ~ Bulter-2/3
        Habl    = 1e3;              % Height of atmospheric boundary layer, m
        alpha   = 0.24;             % Parts of Freely-pass atmospheric boundary layer
        beta    = 170;              % weight of fire intensity in building up the plume, m
        P_f0    = 1e6;              % Reference fire power, W
        gamma   = 0.35;             % power law contribution fo FRP
        delta   = 0.6;              % Dependence to the free troposphere(FT)
        N2      = 2.5e-4;           % Brunt Vasala Frequency in FT, s^-2
        zp      = 0.45;             % Z Score Percentile, p=67
        beta3   = 0.945;
        d       = 10;                % Unit depth of fire zone,m
        L_f     = beta0*FLIN^beta1;
        Fr      = U_wind^2/r/g;
        N_FT2   = 2.789e-4;         % Brunt Vasala Frequency in FT
        Hmax    = alpha*Habl+beta*(FLIN/d/P_f0)^gamma*exp(-delta*N_FT2/N2);
        nu      = 0.4;              %fraction of injection height
        
        MU_X    = nu*Hmax*(3/2*rho_inf/rho_f*C_d)^0.5*U_wind;
        MU_DIST = log(MU_X);
%         SIGMA_DIST = 1/(zp)*log(Fr^0.5+beta3*(2/3*rho_f/rho_inf*U_wind^2/C_d/g/L_f)^0.5); % Flame incline neglected
        SIGMA_DIST = 1/(zp)*log(Fr^0.5); % Flame incline neglected
        MU_OUT=MU_DIST;
        SIGMA_OUT=SIGMA_DIST;

% 
%         LogNormal = true;
%         rho_inf = 1.1;             % air density, kg/m^3
%         rho_f   = 200;              % wild-land fuel density
%         C_d     = 0.45;             % Drag coefficient
%         g       = 9.81;              % Gravational acceleration, m/s^2
%         r       = 0.84;             % Firebrand radius, m
%         beta0   = 0.026;            % Byram-7.75e-2, Clark-7.22e-4, Wilgen-7.5e-3, Fons-0.127, Anderson-0.0447, Wang-0.026445, Bulter-0.0175
%         beta1   = 2/3;              % Byram-0.46,    Clark-0.99,    Wilgen-0.46,   Fons ~ Bulter-2/3
%         Habl    = 1e2;              % Height of atmospheric boundary layer, m
%         alpha   = 0.24;             % Parts of Freely-pass atmospheric boundary layer
%         beta    = 170;              % weight of fire intensity in building up the plume, m
%         P_f0    = 1e6;              % Reference fire power, W
%         gamma   = 0.35;             % power law contribution fo FRP
%         delta   = 0.6;              % Dependence to the free troposphere(FT)
%         N2      = 2.5e-4;           % Brunt Vasala Frequency in FT, s^-2
%         zp      = 0.45;             % Z Score Percentile, p=67
%         beta3   = 0.945;
%         d       = 1;                % Unit depth of fire zone,m
%         L_f     = beta0*FLIN^beta1;
%         Fr      = U_wind^2/r/g;
%         N_FT2   = 2.789e-4;         % Brunt Vasala Frequency in FT
%         Hmax    = alpha*Habl+beta*(FLIN/d/P_f0)^gamma*exp(-delta*N_FT2/N2);
%         nu      = 0.4;              %fraction of injection height
%         
%         MU_X    = nu*Hmax*(3/2*rho_inf/rho_f*C_d)^0.5;
%         MU_DIST = log(MU_X);
%         SIGMA_DIST = 1/(2*zp)*log(Fr); % Flame incline neglected
%         MU_OUT=exp(MU_DIST+0.5*SIGMA_DIST^2);
%         SIGMA_OUT=sqrt(MU_OUT^2*(exp(SIGMA_DIST^2)-1));
%         SIGMA_DIST = 1/zp*log(Fr^1/2+beta3*(2/3*rho_f/rho_inf*U_wind^2/C_d*g*L_f)^0.5); %
%         fprintf("MU=%.2f,SIGMA=%.2f\n",MU_DIST, SIGMA_DIST)
end


end

