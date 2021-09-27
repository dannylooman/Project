%%Script used for greybox identification of rotational pendulum
% Danny Looman
%clear; clc;

%% Create option structure
opt = nlgreyestOptions;
opt.Display = 'on';
opt.SearchOptions.MaxIterations = 50;

%% Create Identification data
load("saved_data\07-Sep-2021 11_44_42.mat");
Ts = input.time(2) - input.time(1);
theta1 = conv_theta(theta1); %Preprocess theta1
theta2 = conv_theta(theta2); %Preprocess theta1

% Transform timeseries to arrays and shrink input array to same size as
% output array
y = [theta1.Data(:,1), theta2.Data(:,1), theta1.Data(:,2), theta2.Data(:,2)];
u = input.Data(1:length(theta1.Data), :);

z = iddata(y, u, Ts, 'Name', 'RotPendulum');

%% Create grey box model
file_name = 'model_function_file';
Order = [4 1 5];  % 4 outputs, 1 input, 5 states

Parameters = [struct('Name', 'L1',  'Value', model.L1, 'Unit', 'm',     'Minimum', 0.05,  'Maximum', 0.15, 'Fixed', true);
              struct('Name', 'L2',  'Value', model.L2, 'Unit', 'm',     'Minimum', 0.05,  'Maximum', 0.15, 'Fixed', true);
              struct('Name', 'm_1', 'Value', model.m1, 'Unit', 'kg',    'Minimum', 0.00,  'Maximum', 10.0, 'Fixed', true);
              struct('Name', 'm_2', 'Value', model.m2, 'Unit', 'kg',    'Minimum', 0.00,  'Maximum', 10.0, 'Fixed', true);
              struct('Name', 'C1',  'Value', model.C1, 'Unit', '-',     'Minimum', 0.30,  'Maximum', 1.00, 'Fixed', true);
              struct('Name', 'b2',  'Value', model.b2, 'Unit', '-',     'Minimum', 0.00,  'Maximum', 0.10, 'Fixed', true);
              struct('Name', 'g',   'Value', model.g,  'Unit', 'm/s^2', 'Minimum', 0.00,  'Maximum', 10.0, 'Fixed', true);
              struct('Name', 'R_a', 'Value', model.Ra, 'Unit', 'Ohm',   'Minimum', 0.00,  'Maximum', 5.00, 'Fixed', true);
              struct('Name', 'K_m', 'Value', model.Km, 'Unit', '-',     'Minimum', -5.00, 'Maximum', 5.00, 'Fixed', true);
              struct('Name', 'L_a', 'Value', model.La, 'Unit', 'H',     'Minimum', 0.00,  'Maximum', 5.00, 'Fixed', true);
              ];

InitialStates = [struct('Name', 'x1', 'Value', theta1.data(1,1), 'Unit', 'rad',   'Minimum', -pi, 'Maximum', pi, 'Fixed', true);
                 struct('Name', 'x2', 'Value', theta2.data(1,1), 'Unit', 'rad',   'Minimum', -pi, 'Maximum', pi, 'Fixed', true);
                 struct('Name', 'x3', 'Value', 0.0, 'Unit', 'A',     'Minimum', -0.5, 'Maximum', 0.5, 'Fixed', false);
                 struct('Name', 'x4', 'Value', 0.0, 'Unit', 'rad/s', 'Minimum', -0.5, 'Maximum', 0.5, 'Fixed', false);
                 struct('Name', 'x5', 'Value', 0.0, 'Unit', 'rad/s', 'Minimum', -0.5, 'Maximum', 0.5, 'Fixed', false);
                ];
Sample_time = 0; % Continuous model

init_sys = idnlgrey(file_name, Order, Parameters, InitialStates, Sample_time, 'Name', 'Rotational Pendulum');

%% Run identification
identified_system = nlgreyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)

%% Compare results
compare(z, identified_system);