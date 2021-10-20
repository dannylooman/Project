%%Script used for identification of second link of rotational pendulum
% Danny Looman
clear; clc;
hwinit;

%% Create identification data from multiple experiments
data_array=["20-Oct-2021 11_02_40-no_delay_second_link1",...
            "20-Oct-2021 11_03_34-no_delay_second_link2"];
%         "06-Oct-2021 09_36_58-second_link_100hz",...
%         "06-Oct-2021 09_38_11-second_link_100hz",...
        
for i=1:length(data_array)
    load('saved_data/' + data_array(i) + '.mat');
    Ts = input.time(2) - input.time(1);  % Actual sample time

    y = [theta2.data+0.02, dtheta2.data];
    u = input.Data(1:length(theta2.data));
    
    %     tmp = conv_theta(theta2);
    %     y = [tmp.data(:,1)-pi, tmp.data(:,2)];

    N_end = length(y);
    N_start = max(int16(0.10 * N_end), 1);  % Index integers start at 1
    z_tmp{i} = iddata(y(N_start:N_end,:), u(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'\theta_2'; '\theta_2dot'});
end

z = merge(z_tmp{:});
% %% Create Identification data
% load("saved_data/13-Sep-2021 14_50_03-second_link_swing_100hz_fix.mat");
% 
% Ts = input.time(2) - input.time(1);
% theta2 = conv_theta(theta2);
% %%
% % Transform timeseries to arrays and shrink input array to same size as
% % output array, multiply with -1 makes it better?
% 
% y = [theta2.data(:,1)- 0.016, theta2.data(:, 2)];
% u = input.Data(1:length(theta2.data(:, 1)), :);
% 
% N_end = length(y);
% N_start = int16(0.75 * N_end);
% z = iddata(y(N_start:N_end,:), u(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Angle'; 'Angular velocity'});

%% Linear grey box identification
file_name = 'model_function_file_second_link_linear';

L2 = 0.0881;
b2 = 0.0093;
g = 9.81;

Parameters = {'length', L2; 'damping',b2; 'gravity', g;};

init_sys = idgrey(file_name, Parameters, 'c', 'Name', 'Linear system');
init_sys.Structure.Parameters(1).Free = true;
init_sys.Structure.Parameters(2).Free = true;
init_sys.Structure.Parameters(3).Free = false;

% Run linear identification
opt = greyestOptions;
opt.Display = 'off';
opt.InitialState = 'estimate';
opt.SearchOptions.MaxIterations = 50;

identified_system_linear = greyest(z, init_sys, opt);
disp(identified_system_linear.Report.Parameters.ParVector)

%% Compare results
for i=1:length(data_array) 
    figure(i);
    compare(getexp(z, i), identified_system_linear);
    hold on; title(""); hold off;
end

%% Nonlinear grey box identification
file_name = 'model_function_file_second_link_nonlin';
Order = [2 1 2];  % 1 outputs, 0 input, 2 states

Parameters = [struct('Name', 'L2',  'Value', model.L2, 'Unit', 'm',     'Minimum', 0.05, 'Maximum', 0.15, 'Fixed', false);
              struct('Name', 'b2',  'Value', model.b2, 'Unit', '-',     'Minimum', 0.00, 'Maximum', 1.00, 'Fixed', false);
              struct('Name', 'g',   'Value', model.g,  'Unit', 'm/s^2', 'Minimum', 0.00, 'Maximum', 10.0, 'Fixed', true);
              struct('Name', 'c2',  'Value', 0.0,      'Unit', 'Nm',    'Minimum', 0.00, 'Maximum', 10.0, 'Fixed', true);];

%0.0884, 0.13, 0.011, 9.81, 0.25          
          
InitialStates = [struct('Name', 'x1', 'Value', theta2.data(N_start, 1), 'Unit', 'rad',   'Minimum', -pi, 'Maximum', pi, 'Fixed', false);
                 struct('Name', 'x2', 'Value', 0.0, 'Unit', 'rad/s',   'Minimum', -5, 'Maximum', 5, 'Fixed', false);];
Sample_time = 0; % Continuous model

init_sys = idnlgrey(file_name, Order, Parameters, InitialStates, Sample_time, 'Name', 'Nonlinear system');

% Run Nonlin identification
opt = nlgreyestOptions('Display', 'on');
opt.Display = 'on';
opt.SearchOptions.MaxIterations = 100;
identified_system_nonlin = nlgreyest(z, init_sys, opt);  
disp(identified_system_nonlin.Report.Parameters.ParVector)

% Compare results
compare(z, identified_system_nonlin);
%%
compare(z, identified_system_nonlin, identified_system_linear);
%% save linear model
save("saved_data/second_link_identified_model", 'identified_system_linear')