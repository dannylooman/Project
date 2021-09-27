%%Script used for greybox identification of rotational pendulum
% Danny Looman
clear; clc;
hwinit

%% Create option structure
opt = nlgreyestOptions;
opt.Display = 'on';
opt.SearchOptions.MaxIterations = 50;

%% Create Identification data
load("saved_data\27-Sep-2021 14_14_20-4meas-hangin-down.mat");
%%
Ts = input.time(2) - input.time(1);
theta1 = merge_theta(theta1.data(:,1),theta1.data(:,2)); %Preprocess theta1
theta2 = merge_theta(theta1.data(:,1),theta1.data(:,2)); %Preprocess theta1

% Transform timeseries to arrays and shrink input array to same size as
% output array
y = [theta1.Data(:,1), theta2.Data(:,1), theta1.Data(:,2), theta2.Data(:,2)];
u = input.Data(1:length(theta1.Data), :);
%u = diff(u)/Ts;
%y = y(1:length(u),:);
%nn=215;
%y=y(nn:end,:);
%u=u(nn:end,:);
%plot(y(:,2))
%%
z = iddata(y, u, Ts, 'Name', 'RotPendulum');

%% Create grey box model
file_name = 'model_function_simplified_motor';
Order = [4 1 4];  % 4 outputs, 1 input, 4 states

Parameters = [struct('Name', 'L1', 'Value', model.L1, 'Unit', 'm',      'Minimum', 0.05,  'Maximum', 0.15, 'Fixed', true);
              struct('Name', 'L2', 'Value', model.L2, 'Unit', 'm',      'Minimum', 0.05,  'Maximum', 0.15, 'Fixed', false);
              struct('Name', 'm_2','Value', model.m2, 'Unit', 'kg',     'Minimum', 0.00,  'Maximum', 10.0, 'Fixed', false);
              struct('Name', 'b2', 'Value', model.b2, 'Unit', '-',      'Minimum', 0.00,  'Maximum', 0.10, 'Fixed', false);
              struct('Name', 'g',  'Value', model.g,  'Unit', 'm/s^2',  'Minimum', 0.00,  'Maximum', 10.0, 'Fixed', true);
              struct('Name', 'c',  'Value', model.c,  'Unit','rad/s^2V','Minimum', -10.00, 'Maximum', 10.00, 'Fixed', false);
              struct('Name', 'dt',  'Value', Ts,  'Unit','rad/s^2V','Minimum', -5.00, 'Maximum', 5.00, 'Fixed', true);
              ];

InitialStates = [struct('Name', 'x1', 'Value', theta1.data(1,1), 'Unit', 'rad',   'Minimum', -2*pi, 'Maximum', 2*pi, 'Fixed', false);
                 struct('Name', 'x2', 'Value', theta2.data(1,1), 'Unit', 'rad',   'Minimum', -2*pi, 'Maximum', 2*pi, 'Fixed', false);
                 struct('Name', 'x3', 'Value', 0.0, 'Unit', 'rad/s', 'Minimum', -0.5, 'Maximum', 0.5, 'Fixed', false);
                 struct('Name', 'x4', 'Value', 0.0, 'Unit', 'rad/s', 'Minimum', -0.5, 'Maximum', 0.5, 'Fixed', false);
                ];
            
Sample_time = 0; % Continuous model
init_sys = idnlgrey(file_name, Order, Parameters, InitialStates, Sample_time, 'Name', 'Rotational Pendulum');

%% Run identification
identified_system = nlgreyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
compare(z, identified_system);

STOP
%% Check for Swing!
load("saved_data/13-Sep-2021 14_50_03-second_link_swing_100hz_fix.mat");
Ts = input.time(2) - input.time(1);
theta2 = conv_theta(theta2);
theta1 = conv_theta(theta1);

y = [theta2.data(:,1)- 0.016, theta2.data(:, 2)];
u = input.Data(1:length(theta2.data(:, 1)), :);
N_end = length(y);
N_start = int16(0.75 * N_end);
y=y(N_start:N_end,:);
u=u(N_start:N_end);

fc=10;
x0 = [0; y(1,1)-pi; 0; y(1,2)];
[tq, sts] = simulate_motor(u,x0,model,Ts,fc);

sts_dec_pos = decimatee(sts(:,2)+pi,fc);
sts_dec_spd = decimatee(sts(:,4),fc);
RMSE_pos = comp(y(:,1),sts_dec_pos);
RMSE_spd = comp(y(:,2),sts_dec_spd);

%pos
t=1:fc:length(y)*fc;
figure()
hold on
plot(tq,sts(:,2)+pi)
plot(t,y(:,1))
legend('simulated, '+string(RMSE_pos)+'%','original')
hold off

%speed
figure()
hold
plot(tq,sts(:,4))
plot(t,y(:,2))
legend('simulated, '+string(RMSE_spd)+'%','original')
hold


%% Check for motor!
load("saved_data\15-Sep-2021 09_23_40-freq_sweep_stationary_second_link.mat");

Ts = input.time(2) - input.time(1);
theta1 = conv_theta(theta1);
theta2 = conv_theta(theta2);
filter_gain = Ts / 250.0;% High pass filter theta1 to remove gravity dynamics
theta1_filt = filter([1-filter_gain filter_gain-1],[1 filter_gain-1], theta1.data(:, 1));
y = [theta1_filt, theta1.data(:, 2)];
u = input.data(1:length(theta1.data), :);

fc=20;
x0 = [y(1,1); 0; y(1,2); 0];
[tq, sts] = simulate_motor(u,x0,model,Ts,fc);

%NRMSE metrics
sts_dec_pos = decimatee(sts(:,1),fc);
sts_dec_spd = decimatee(sts(:,3),fc);
RMSE_pos = comp(y(:,1),sts_dec_pos);
RMSE_spd = comp(y(:,2),sts_dec_spd);

%pos
t=1:fc:length(y)*fc;
figure()
hold on
plot(tq,sts(:,1))
plot(t,y(:,1))
legend('simulated, '+string(RMSE_pos)+'%','original')
hold off

%speed
figure()
hold
plot(tq,sts(:,3))
plot(t,y(:,2))
legend('simulated, '+string(RMSE_spd)+'%','original')
hold
%% Check for corssterms
load("saved_data\27-Sep-2021 14_14_20-4meas-hangin-down.mat");

Ts = input.time(2) - input.time(1);
theta1 = conv_theta(theta1);
theta2 = merge_theta(theta2,dtheta2);
filter_gain = Ts / 250.0;% High pass filter theta1 to remove gravity dynamics
theta1_filt = filter([1-filter_gain filter_gain-1],[1 filter_gain-1], theta1.data(:, 1));
y = [theta1_filt, theta2.data(:, 1), theta1.data(:,2), theta2.data(:, 2)];
u = input.data(1:length(theta1.data), :);

fc=20;
x0 = [y(1,1); 0; y(1,2); 0];
[tq, sts] = simulate_motor(u,x0,model,Ts,fc);

%NRMSE metrics
sts_dec_pos1 = decimatee(sts(:,1),fc);
sts_dec_pos2 = decimatee(sts(:,2),fc);
sts_dec_spd1 = decimatee(sts(:,3),fc);
sts_dec_spd2 = decimatee(sts(:,4),fc);
RMSE_pos1 = comp(y(:,1),sts_dec_pos1);
RMSE_pos2 = comp(y(:,2),sts_dec_pos2);
RMSE_spd1 = comp(y(:,3),sts_dec_spd1);
RMSE_spd2 = comp(y(:,4),sts_dec_spd2);

%pos1
t=1:fc:length(y)*fc;
figure()
hold on
plot(tq,sts(:,1))
plot(t,y(:,1))
legend('simulated, '+string(RMSE_pos1)+'%','original')
title('Theta_1')
hold off

%pos2
figure()
hold on
plot(tq,sts(:,2))
plot(t,y(:,2))
legend('simulated, '+string(RMSE_pos2)+'%','original')
title('Theta_2')
hold off

%speed1
figure()
hold
plot(tq,sts(:,3))
plot(t,y(:,3))
legend('simulated, '+string(RMSE_spd1)+'%','original')
title('D theta_1')
hold

%speed2
figure()
hold
plot(tq,sts(:,4))
plot(t,y(:,4))
legend('simulated, '+string(RMSE_spd2)+'%','original')
title('D theta_2')
hold

%% Swing only
fc=30;
n=length(u)*fc;
t1=1:fc:n;
t2=1:1:n;
y_pred=zeros(n,2);
y_pred(1,1)=y(1,1);
y_pred(1,2)=y(1,2);
for i=2:n
    [dx,~] = model_function_file_second_link_swing(0,y_pred(i-1,:),0,model.L2,model.m2,model.b2,model.g,0);
    y_pred(i,:) = y_pred(i-1,:)+dx'*Ts/fc;
end

figure()
hold on
plot(t2,y_pred(:,1))
plot(t1,y(:,1))
legend('simulated','original')
hold off

%% Functions
function [tq,sts] = simulate_motor(u,x0,model,Ts,fc)
    model_function_simplified_motor(0,[0,0,0,0],u(1),model.L1,model.L2,model.m2,model.b2,model.g,model.c,Ts); %set u_prev=u(1)
    
    n=length(u)*fc;
    sts=zeros(n,4);
    sts(1,:)=x0;
    t=1:fc:n;
    tq=1:1:n;
    u = interp1(t,u,tq);
    Ts = Ts/fc;
    
    for i=2:n
        [dx,~] = model_function_simplified_motor(0,sts(i-1,:),u(i-1),model.L1,model.L2,model.m2,model.b2,model.g,model.c,Ts);
        sts(i,:) = sts(i-1,:)+dx'*Ts;
    end
end

function ret = comp(y,x) % Matlab metrics for model accuray (y-original,x-model)
    NRMSE = norm((y-x)) / norm((y-mean(y)));
    ret = (1-NRMSE)*100;
end

function ret = decimatee(y,n) % Decimate function
ret = zeros(int32(length(y)/n),1);
for i=0:length(ret)-1
    ret(i+1) = y(1+n*i);
end
end