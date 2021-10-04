clear; clc; close all;
hwinit;
load("saved_data\model_full_system_4_states.mat");

%%
sys = ss(sys);
sys.A(4,3) = 1 * sys.A(4,3);

sys.A(3,1) = 1 * sys.A(3,1);
sys.A(3,2) = 1 * sys.A(3,2);
sys.A(4,1) = 1 * sys.A(4,1);
sys.A(4,2) = 1 * sys.A(4,2);

%% Kalman filter
Q_kf = 1 * diag([1, 1, 1, 1]);
R_kf = 10 * diag([1, 10, 1, 10]);

%%
% state_feedbackgain
Q_lqr = [1.1, 0, 1, 0;
         0, 0, 0, 0;
         1, 0, 1, 0;
         0, 0, 0, 0;];
     
R_lqr = 0.2;
K = dlqr(sys.A, sys.B, Q_lqr, R_lqr);


% Closed loop system
discrete_cl = ss(sys.A - sys.B*K, sys.B, sys.C, sys.D, sys.Ts);   
K_ff = 1/dcgain(discrete_cl); 


%% Validate control gain

opt = stepDataOptions('StepAmplitude', [1/(dcgain_sys(1))]);
[y_ct, t_ct, x_ct] = step(discrete_cl, 20, opt);
ct_data = timeseries(y_ct, t_ct);

figure(); hold on;
plot(t_ct, y_ct(:,1));
plot(t_ct, y_ct(:,2));
plot(t_ct, y_ct(:,3));
plot(t_ct, y_ct(:,4));
legend("\theta_1", "dot \theta_1", "\theta_2", "dot \theta_2");


