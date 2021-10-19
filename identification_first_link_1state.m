%%Script used for greybox identification of frist link of rotational pendulum
% Danny Looman
clear; clc;
hwinit;

%% Create identification data from multiple experiments
%"06-Oct-2021 09_44_13-first_link_100hz",...

% data_array = ["19-Oct-2021 10_47_14-identification_first_link_square_wave"];

data_array=["06-Oct-2021 09_44_53-first_link_100hz",...
            "06-Oct-2021 09_46_01-first_link_100hz",...
            "18-Oct-2021 13_31_52-full_system_100hz",...
            "19-Oct-2021 10_47_14-identification_first_link_square_wave",...
            "18-Oct-2021 13_32_43-full_system_100hz"];
        
for i=1:length(data_array)
    load('saved_data/' + data_array(i) + '.mat');
    Ts = input.time(2) - input.time(1);  % Actual sample time

    y = theta1.data - pi;
    u = input.Data(1:length(theta1.data));

    N_end = length(y);
    N_start = max(int32(0.05 * N_end), 1);  % Index integers start at 1
    z_tmp{i} = iddata(y(N_start:N_end,:), u(N_start:N_end, :), Ts, 'Name', 'RotPendulum', 'OutputName', {'\theta_1'});
end

z = merge(z_tmp{:});

%% Linear grey box identification
file_name = 'model_function_file_first_link_linear_1state';

c = 0;
K1 = -6.24;

Parameters = {'constant', c; 'Motor Constant', K1;};

init_sys = idgrey(file_name, Parameters, 'c');
init_sys.Structure.Parameters(1).Free = false;
init_sys.Structure.Parameters(2).Free = true;

% Run linear identification
opt = greyestOptions;
opt.Display = 'on';
opt.InitialState = 'estimate';
opt.SearchOptions.MaxIterations = 50;
opt.EnforceStability = true;

identified_system = greyest(z, init_sys, opt);
disp(identified_system.Report.Parameters.ParVector)


%% Compare results
for i=1:length(data_array)
    figure()
    compare(getexp(z, i), identified_system);
end

%% Validation data
load("saved_data/28-Sep-2021 10_31_04-first_link_validation.mat");  % first link data
y_val = [theta1.data, dtheta1.data];
u_val = input.Data(1:length(theta1.data));

N_end = length(y_val);
N_start = max(int16(0.1 * N_end), 1);  % Index integers start at 1
z_val = iddata(y_val(N_start:N_end,:), u_val(N_start:N_end), Ts, 'Name', 'RotPendulum', 'OutputName', {'Angle'; 'Angular velocity'});


%% Save model to file
save("saved_data/first_link_identified_model_1state", 'identified_system')