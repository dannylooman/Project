% Sensor saving script

filename = replace(strcat("saved_data\", datestr(datetime), "-block_signal_stationary_second_link.mat"),':','_');
save(filename, 'theta1', 'theta2', 'input')