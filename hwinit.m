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
model.L1=0.1;
model.L2=0.0882;
model.m2=0.0139;
model.b2=0.0110;
model.g=9.81;
model.c=-6.8;

model.C1=0.6;
model.m1=0.9196;
model.Ra=0.1560;
model.Km=-0.1469;
model.La=0.02;