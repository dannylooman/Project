raw_theta2_data = raw_theta2.Data();

min_th2 = min(raw_theta2_data)
max_th2 = max(raw_theta2_data)
mean_th2 = mean(raw_theta2_data)

gain_theta2 = -pi / mean(raw_theta2_data) 
check_value = (max_th2 - min_th2) / (2*pi)


raw_theta1_data = raw_theta1.Data();

min_th1 = min(raw_theta1_data)
max_th1 = max(raw_theta1_data)
mean_th1 = mean(raw_theta1_data)

gain_theta1 = -pi / mean(raw_theta1_data) 
check_value = (max_th1 - min_th1) / (2*pi)
