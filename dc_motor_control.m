clear; clc; close all;
hwinit;
load("saved_data\dcmotor_sys.mat");
load("saved_data\15-Sep-2021 09_50_03-freq_sweep_stationary_second_link.mat")

theta1 = conv_theta(theta1);
Ts = input.time(2) - input.time(1);

% Kalman filter
Q_kf = diag([0.1, 0.001, 0.1]);
R_kf = eye(2);

% state_feedbackgain
Q_lqr = diag([1, 0.1, 0.01]);
R_lqr = 1;
K = dlqr(dc_motor_ss.A, dc_motor_ss.B, Q_lqr, R_lqr);




