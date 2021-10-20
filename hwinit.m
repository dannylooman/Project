%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DSCS FPGA interface board: init and I/O conversions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Import paths
addpath('functions')
addpath('models')
addpath('saved_data')

% gains and offsets
daoutoffs = [0.00];                   % output offset
daoutgain = 1*[-6];                   % output gain

% Sensor calibration:
adinoffs = -[1.1671 3.8452];
adingain = [1.2096 1.2156];

adinoffs = [adinoffs 0 0 0 0 0];     % input offset
adingain = [adingain 1 1 1 1 1];     % input gain (to radians)

% Other initialisation
h = 0.008;  % Accoarding to other group is this the fastest sampling frequency
lowpass_gain = 0.03;

%Model parameters
%m_1, m_2, C1, b2, g, R_a, K_m ,L_a
model.L1 = 0.1;
model.L2 = 0.0882;
model.m1 = 0.2436;
model.m2 = 0.05;
model.C1 = 0.6;
model.b2 = 0.0001;
model.g  = 9.81;
model.Ra = 0.0000151;
model.Km = -0.1374;
model.La = 4.4e-5;

model.c=-6.8;