clear; clc; close all;
hwinit;
load("saved_data\dcmotor_sys.mat");
load("saved_data\15-Sep-2021 09_50_03-freq_sweep_stationary_second_link.mat")

theta1 = conv_theta(theta1);
Ts = input.time(2) - input.time(1);
%%
% Kalman filter
Q_kf = diag([0.01, 0.1, 1])/1000000;
R_kf = eye(2)*100;
%%
% state_feedbackgain
Q_lqr = 1*diag([1, 0.1, 0.01]);
R_lqr = 1;
K = dlqr(dc_motor_ss.A, dc_motor_ss.B, Q_lqr, R_lqr);


% Closed loop system
discrete_cl_dcmotor = ss(dc_motor_ss.A - dc_motor_ss.B*K, ...
                         dc_motor_ss.B, dc_motor_ss.C, dc_motor_ss.D, Ts);   
K_ff = 1/dcgain(discrete_cl_dcmotor); 


%% Validate control gain

opt = stepDataOptions('StepAmplitude', [1/dcgain(discrete_cl_dcmotor), 0]);
[y_ct, t_ct, x_ct] = step(discrete_cl_dcmotor, 20);
ct_data = timeseries(y_ct, t_ct);

figure(); hold on;
plot(t_ct, y_ct(:,1));
plot(t_ct, y_ct(:,2));
legend("y1", "y2");


