clear; clc; close all;
hwinit;
load("saved_data\model_full_system_4_states.mat");

%% Kalman filter
Q_kf = 1 * diag([1, 1, 1, 1]);
R_kf = 10 * diag([1, 10, 1, 10]);

%%
% state_feedbackgain
Q_lqr = [1, 0, 1, 0;
         0, 0, 0, 0;
         1, 0, 1, 0;
         0, 0, 0, 0;];
     
R_lqr = 0.1;
K = dlqr(sys.A, sys.B, Q_lqr, R_lqr);


% Closed loop system
discrete_cl = ss(sys.A - sys.B*K, sys.B, sys.C, sys.D, sys.Ts);   
K_ff = 1/dcgain(discrete_cl); 


%% Validate control gain

opt = stepDataOptions('StepAmplitude', [1/dcgain(discrete_cl_dcmotor), 0]);
[y_ct, t_ct, x_ct] = step(discrete_cl_dcmotor, 20);
ct_data = timeseries(y_ct, t_ct);

figure(); hold on;
plot(t_ct, y_ct(:,1));
plot(t_ct, y_ct(:,2));
legend("y1", "y2");


