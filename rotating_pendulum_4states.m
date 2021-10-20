clear; clc; close all;
hwinit;

run_on_backup_model = false;

if run_on_backup_model
    load("saved_data\backup\20211005_model_full_system_4_states.mat");
    sys = ss(sys);
    [A,B,C,D,Ts]=ssdata(sys);
    A(2:end,1)=-A(2:end,1);
    A(1:end,3)=-A(1:end,3);
    A(3,3)=-A(3,3);
    sys = ss(A,B,C,D,Ts);
else
    load("saved_data\model_full_system_4_states.mat");
    sys = ss(sys);

    
    sys.A(4,1) = sys.A(4,1);
    sys.A(4,2) = sys.A(4,2);
    sys.A(4,3) = sys.A(4,3);
end


%% Discretize system
if run_on_backup_model
    dt_sys_zoh = d2d(sys, h, 'zoh');
    dt_sys_tustin = d2d(sys, h, 'tustin');   
else
    dt_sys_zoh = c2d(sys, h, 'zoh');
    dt_sys_tustin = c2d(sys, h, 'tustin');
end


%% Kalman filter
Q_kf = 1 * diag([1, 1, 1, 1]);
R_kf = 1 * diag([1, 10, 1, 10]);

%%
% state_feedbackgain
Q_lqr = [1, 0, 1, 0;
         0, 0, 0, 0;
         1, 0, 1, 0;
         0, 0, 0, 0;];
     
R_lqr = .2;
K = dlqr(dt_sys_tustin.A, dt_sys_tustin.B, Q_lqr, R_lqr)
K(2) = K(2);
K(3) = K(3);
K(4) = K(4);
 
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
plot(t_ct, y_ct(:,4));
legend("\theta_1", "dot \theta_1", "\theta_2", "dot \theta_2");


