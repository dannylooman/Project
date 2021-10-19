clear; clc; close all;
hwinit;

load("saved_data\model_full_system_3_states.mat");
sys = ss(sys);

% sys.A(3,2) = -sys.A(3,2);
% sys.A(3,1) = -sys.A(3,1);

%% Discretize system

dt_sys_zoh = c2d(sys, h, 'zoh');
dt_sys_tustin = c2d(sys, h, 'tustin');



%% Kalman filter
Q_kf = 1 * diag([1, 1, 1]);
R_kf = 50 * diag([1, 1, 10]);

%%
% state_feedbackgain
Q_lqr = [1.01, 1, 0;
         1, 1, 0;
         0, 0, 0;];
     
R_lqr = 0.1;

% K = lqr(sys.A, sys.B, Q_lqr, R_lqr);
K = dlqr(dt_sys_tustin.A, dt_sys_tustin.B, Q_lqr, R_lqr);
K(2) = -K(2);
 
% Closed loop system
discrete_cl = ss(dt_sys_tustin.A - dt_sys_tustin.B*K, dt_sys_tustin.B, ...
                 dt_sys_tustin.C, dt_sys_tustin.D, dt_sys_tustin.Ts); 

dcgain_sys = dcgain(discrete_cl);
K_ff = 1/dcgain_sys; 


%% Validate control gain
impulse(discrete_cl)
%%
opt = stepDataOptions('StepAmplitude', [1/(dcgain_sys(1))]);
[y_ct, t_ct, x_ct] = step(discrete_cl, 20, opt);
ct_data = timeseries(y_ct, t_ct);

figure(); hold on;
plot(t_ct, y_ct(:,1));
plot(t_ct, y_ct(:,2));
plot(t_ct, y_ct(:,3));
legend("\theta_1", "\theta_2", "dot \theta_2");


