% Meteology
U_wind = 15; % Wind velocity, mph

% Topography
a_0    = 23;     % Average building plan dimension, m
d      = 45;     % Average building seperation, m
f_b    = 0.0;    % Ratio of fire resistance buildings
Fuel_1 = [102   15000  30000];  % [Fuel# LeftBoundary RightBoundary] 
Fuel_2 = [102    0     15000];  % [Fuel# LeftBoundary RightBoundary]
M1     = 0;
M10    = 0;
M100   = 0;
MLH    = 0;
MLW    = 0;
CC     = 0;
CH     = 0;

% Ember setting
ENABLE_SPOTTING            = true;
SPOTTING_DISTRIBUTION_TYPE = 2; % 1-, 2- 3- ,
NEMBERS_MIN              = 10;
NEMBERS_MAX              = 10;
MIN_SPOTTING_DISTANCE    = 100;
MAX_SPOTTING_DISTANCE    = 100;
CRITICAL_SPOTTING_FIRELINE_INTENSITY =1;
PIGN                     = 100; 
SURFACE_FIRE_SPOTTING_PERCENT = 100;

% Time settings
SimuTime   = 60000; % Total time, s
delT       = 30;    % Time step, s

% Spatial settings
delX          = 30;            % Cell size, m
SimuRegion    = [0 30000];  % Simulation region, m
Ignition      = 300;              % Ignition point location, m
BANDTHICKNESS = 5;