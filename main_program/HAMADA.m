function C = HAMADA(C, U_wind, a_0, d, f_b)
% COEFFICIENT FOR HAMADA MODEL 

C_14 = 1.6; C_24 = 0.1; C_34 = 0.007; C_44 = 25.0; C_54 = 2.5 ; 
C_1S = 1.0; C_2S = 0.0; C_3S = 0.005; C_4S = 5.0 ; C_5S = 0.25;  
C_1U = 1.0; C_2U = 0.0; C_3U = 0.002; C_4U = 5.0 ; C_5U = 0.2;


% HAMADA ELLIPSE DEFINITION 
X_T = 120.0;      % TIME IN MINUTES 
V   = U_wind*0.447; % m/s
A_0 = a_0;%23        % AVERAGE BUILDING PLAN DIMENSION , M 
D   = d;%45         % AVERAGE BUILDING SEPERATION , M 
F_B = f_b;%0       % RATIO OF FIRE RESISTANCE BUILDINGS

CV_4 = C_14 * ( 1 + C_24 * V + C_34 * V ^ 2 ) ;
CV_S = C_1S * ( 1 + C_2S * V + C_3S * V ^ 2 ) ;
CV_U = C_1U * ( 1 + C_2U * V + C_3U * V ^ 2 ) ;

% TIME IN MINUTES THE FULLY DEVELOPED FIRE REQUIRES TO ADVANCE TO THE NEXT BUILDING 
T_4 = (( 1-F_B ) * ( 3 + 0.375 * A_0 + ( 8 * D / ( C_44 + C_54 * V ) ) ) + ...
      F_B * ( 5 + 0.625 * A_0 + 16 * D / ( C_44 + C_54 * V ) ) )/ CV_4 ;
T_S = (( 1-F_B ) * ( 3 + 0.375 * A_0 + ( 8 * D / ( C_4S + C_5S * V ) ) ) + ... 
      F_B * ( 5 + 0.625 * A_0 + 16 * D / ( C_4S + C_5S * V ) )) / CV_S ;
T_U = (( 1-F_B ) * ( 3 + 0.375 * A_0 + ( 8 * D / ( C_4U + C_5U * V ) ) ) + ... 
      F_B * ( 5 + 0.625 * A_0 + 16 * D / ( C_4U + C_5U * V ) ) )/ CV_U ;

K_D = max(( A_0 + D ) / T_4 * X_T ,1E-10);
K_S = max(( A_0 / 2 + D ) + ( A_0 + D ) / T_S * ( X_T-T_S ),1E-10) ;
K_U = max(( A_0 / 2 + D ) + ( A_0 + D ) / T_U * ( X_T-T_U ),1E-10);

V_D = max(( A_0 + D ) / T_4,1E-10) ;
V_S = max(( A_0 + D ) / T_S,1E-10) ;
V_U = max(( A_0 + D ) / T_U,1E-10) ;
% HAZUS CORRECTION
if(V <= 10)
   
   V_D_C = max(V_D * V / 10 + ...
            ( K_D * V_S + V_D * K_S + K_U * V_S + V_U * K_S ) * ...
           sqrt( 2 / ( K_D + K_U )/K_S ) * ( 1-V / 10 )/4,1E-10);
   V_S_C = max(V_S * V / 10 + ...
            ( K_D * V_S + V_D * K_S + K_U * V_S + V_U * K_S ) * ...
           sqrt( 2 / ( K_D + K_U )/K_S ) * ( 1-V / 10 )/4,1E-10);
   V_U_C = max(V_U * V / 10 + ...
            ( K_D * V_S + V_D * K_S + K_U * V_S + V_U * K_S ) * ...
           sqrt( 2 / ( K_D + K_U )/K_S ) * ( 1-V / 10 )/4 ,1E-10);

   V_D = V_D_C;
   V_S = V_S_C ;
   V_U = V_U_C ;%M/min
end

if(min(K_D,min(K_S,K_U)) <= 1E-1)
    V_D = K_D/max(X_T,1E-10);
    V_S = K_S/max(X_T,1E-10);
    V_U = K_U/max(X_T,1E-10);
end
C.VELOCITY_DMS = V_D /0.3048;
C.VBACK = V_U/0.3048;
C.LOW = min((V_D+V_U)/2/V_S,10.0);
end