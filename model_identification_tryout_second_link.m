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

% Transform timeseries to arrays and shrink input array to same size as
% output array, multiply with -1 makes it better?
y = [unwrap(theta2.Data)];
u = input.Data(1:length(theta2.Data), :);

z = iddata(y, u, Ts, 'Name', 'RotPendulum', 'OutputUnit', ['rad']);

%% Create grey box model
file_name = 'model_function_file_second_link_swing';
Order = [1 1 2];  % 1 outputs, 0 input, 2 states

Parameters = [struct('Name', 'L2',  'Value', 0.0884, 'Unit', 'm',     'Minimum', 0.05, 'Maximum', 0.15, 'Fixed', true);
              struct('Name', 'm_2', 'Value', 0.1300, 'Unit', 'kg',    'Minimum', 0.00, 'Maximum', 1.00, 'Fixed', false);
              struct('Name', 'b2',  'Value', 0.0110, 'Unit', '-',     'Minimum', 0.00, 'Maximum', 0.10, 'Fixed', false);
              struct('Name', 'g',   'Value', 9.8100, 'Unit', 'm/s^2', 'Minimum', 0.00, 'Maximum', 10.0, 'Fixed', true);
              struct('Name', 'c2',  'Value', 0.0000, 'Unit', 'Nm',    'Minimum', 0.00, 'Maximum', 10.0, 'Fixed', true);];

%0.0884, 0.13, 0.011, 9.81, 0.25          
          
          
InitialStates = [struct('Name', 'x1', 'Value', theta2.Data(1), 'Unit', 'rad',   'Minimum', -pi, 'Maximum', pi, 'Fixed', true);
                 struct('Name', 'x2', 'Value', 0.0, 'Unit', 'rad',   'Minimum', -0.5, 'Maximum', 0.5, 'Fixed', true);];
Sample_time = 0; % Continuous model

init_sys = idnlgrey(file_name, Order, Parameters, InitialStates, Sample_time, 'Name', 'Rotational Pendulum');

%% Run identification
identified_system = nlgreyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
compare(z, identified_system);