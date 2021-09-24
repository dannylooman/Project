%%Script used for greybox identification of rotational pendulum
% Danny Looman
%clear; clc;

%% Create option structure
opt = nlgreyestOptions;
opt.Display = 'on';
opt.SearchOptions.MaxIterations = 100;

%% Create Identification data
load("saved_data/13-Sep-2021 14_50_03-second_link_swing_100hz_fix.mat");
%%
Ts = input.time(2) - input.time(1);
theta2 = conv_theta(theta2);
%%
% Transform timeseries to arrays and shrink input array to same size as
% output array, multiply with -1 makes it better?

y = [theta2.data(:,1)- 0.016, theta2.data(:, 2)];
u = input.Data(1:length(theta2.data(:, 1)), :);

N_end = length(y);
N_start = int16(0.75 * N_end);
z = iddata(y(N_start:N_end,:), u(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Angle'; 'Angular velocity'});
%% Create grey box model
file_name = 'model_function_file_second_link_swing';
Order = [2 1 2];  % 1 outputs, 0 input, 2 states

Parameters = [struct('Name', 'L2',  'Value', 0.0882, 'Unit', 'm',     'Minimum', 0.05, 'Maximum', 0.15, 'Fixed', true);
              struct('Name', 'm_2', 'Value', 0.0107, 'Unit', 'kg',    'Minimum', 0.00, 'Maximum', 1.00, 'Fixed', false);
              struct('Name', 'b2',  'Value', 0.0017, 'Unit', '-',     'Minimum', 0.00, 'Maximum', 0.10, 'Fixed', false);
              struct('Name', 'g',   'Value', 9.8100, 'Unit', 'm/s^2', 'Minimum', 0.00, 'Maximum', 10.0, 'Fixed', true);
              struct('Name', 'c2',  'Value', 0.0, 'Unit', 'Nm',    'Minimum', 0.00, 'Maximum', 10.0, 'Fixed', false);];

%0.0884, 0.13, 0.011, 9.81, 0.25          
          
InitialStates = [struct('Name', 'x1', 'Value', theta2.data(N_start, 1), 'Unit', 'rad',   'Minimum', -pi, 'Maximum', pi, 'Fixed', false);
                 struct('Name', 'x2', 'Value', 0.0, 'Unit', 'rad/s',   'Minimum', -5, 'Maximum', 5, 'Fixed', false);];
Sample_time = 0; % Continuous model

init_sys = idnlgrey(file_name, Order, Parameters, InitialStates, Sample_time, 'Name', 'Rotational Pendulum');

%% Run identification
identified_system = nlgreyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
compare(z, identified_system);