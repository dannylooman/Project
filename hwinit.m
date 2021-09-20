%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DSCS FPGA interface board: init and I/O conversions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Import paths
addpath('scripts')
addpath('models')

% gains and offsets
daoutoffs = [0.00];                   % output offset
daoutgain = 1*[-6];                   % output gain

% Sensor calibration:
adinoffs = -[1.1671 3.8452];
adingain = [1.2096 1.2156];

adinoffs = [adinoffs 0 0 0 0 0];    % input offset
adingain = [adingain 1 1 1 1 1];     % input gain (to radians)

% Other initialisation
h = 0.001;

%Model parameters
%m_1, m_2, C1, b2, g, R_a, K_m ,L_a
model.L1=1.0;
model.L2=0.0884;
model.m1=0.1;
model.m2=0.1124;
model.b2=0.0125;
model.g=9.81;
model.Ra=0.2000;
model.Km=-0.5;
model.La=0.02;