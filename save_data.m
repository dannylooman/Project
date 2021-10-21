% Sensor saving script

filename = replace(strcat("saved_data\", datestr(datetime), "-stabelizing_upward_4_with_disturbance.mat"),':','_');
save(filename, 'theta1', 'theta2', 'dtheta1', 'dtheta2', 'input', 'x_filtered', 'Q_lqr', 'R_lqr' ,'Q_kf', 'R_kf', 'K', 'sys')

%% For loading into Simulink
theta1 = conv_theta(theta1);
%% save in format 7.3 for simulink load
save 'saved_data/observer_theta1_01.mat' -v7.3 theta1
save 'saved_data/observer_input_01.mat' -v7.3 input