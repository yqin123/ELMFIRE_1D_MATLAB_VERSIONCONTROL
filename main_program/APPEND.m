
function DL2 = APPEND(DL2, IX, IS_LISTBURNED, T, FuelMap, M1, M10, M100, MLH, MLW, SLP, U_wind, WAF)
CONVERSION_FACTOR = 5280./60.;
% If the list is empty
if(isempty(DL2))
    DL2 = SIMU_VAR_INIT();
    DL2.IX         =  IX;
    DL2.TIME_ADDED =  T;
    DL2.IFBFM   =  FuelMap(IX);
    DL2.M1      =  M1(IX);
    DL2.M10     =  M10(IX);
    DL2.M100    =  M100(IX);
    DL2.MLH     =  MLH;
    DL2.MLW     =  MLW;
    DL2.TANSLP2 =  tan(SLP);
    DL2.WSMF    =  U_wind * WAF(DL2.IX) * CONVERSION_FACTOR;
else
    LEN=length(DL2)+1;
    % Add new element ot the end
    DL2(LEN)            =  DL2(1);
    DL2(LEN).IX         =  IX;
    DL2(LEN).TIME_ADDED =  T;

    if (~ IS_LISTBURNED)
        DL2(LEN).IFBFM   =  FuelMap(IX);
        DL2(LEN).TANSLP2 =  tan(SLP);
        DL2(LEN).M1      =  M1(IX);
        DL2(LEN).M10     =  M10(IX);
        DL2(LEN).M100    =  M100(IX);
        DL2(LEN).MLH     =  MLH;
        DL2(LEN).MLW     =  MLW;
        DL2(LEN).TANSLP2 =  tan(SLP);
        DL2(LEN).WSMF         =  U_wind * WAF(IX) * CONVERSION_FACTOR;
    end
end
   
end