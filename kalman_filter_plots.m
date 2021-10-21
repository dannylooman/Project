clear; clc;

rotating_pendulum_4states;
load("saved_data\20-Oct-2021 11_40_20-result_Kalman_filter.mat");
sim('kalman_filter_run', input.time(end)); 

%% Figure problem
% clf(figure(1)); figure(1); hold on; grid on;
% plot(dtheta1.time, dtheta1.data, 'linewidth', 1)
% ylim([-5, 5]);
% xlabel("time [s]"); ylabel("Angular Velocity [rad/s]");
% legend("raw");
% saveas(figure(1), 'images/noisy_data_dtheta1.eps', 'epsc');


%% Figure improvement
clf(figure(2)); figure(2); hold on; grid on;
plot(theta1.time, theta1.data-pi, 'linewidth', 1)
plot(x_filtered.time, x_filtered.data(:,1), ':', 'linewidth', 2)
xlabel("time [s]"); ylabel("Angular Position [rad]");
legend("raw", "Kalman Filtered");
saveas(figure(2), 'images/kalman_filter_theta1_improvement.eps', 'epsc');

clf(figure(3)); figure(3); hold on; grid on;
plot(dtheta1.time, dtheta1.data, 'linewidth', 1)
plot(x_filtered.time, x_filtered.data(:,2), 'linewidth', 2)
ylim([-5, 5]);
xlabel("time [s]"); ylabel("Angular Velocity [rad/s]");
legend("raw", "Kalman Filtered");
saveas(figure(3), 'images/kalman_filter_dtheta1_improvement.eps', 'epsc');

clf(figure(4)); figure(4); hold on; grid on;
plot(theta2.time, theta2.data, 'linewidth', 1)
plot(x_filtered.time, x_filtered.data(:,3), ':', 'linewidth', 2)
xlabel("time [s]"); ylabel("Angular Position [rad]");
legend("raw", "Kalman Filtered");
saveas(figure(4), 'images/kalman_filter_theta2_improvement.eps', 'epsc');

clf(figure(5)); figure(5); hold on; grid on;
plot(dtheta2.time, dtheta2.data, 'linewidth', 1)
plot(x_filtered.time, x_filtered.data(:,4), 'linewidth', 2)
xlabel("time [s]"); ylabel("Angular Velocity [rad/s]");
ylim([-5, 5]);
legend("raw", "Kalman Filtered");
saveas(figure(5), 'images/kalman_filter_dtheta2_improvement.eps', 'epsc');

%% RMSE comparison
load('saved_data\20-Oct-2021 11_02_40-no_delay_second_link1.mat');
sim('kalman_filter_run', input.time(end)); 

clf(figure(6)); figure(6); hold on; grid on;
histogram(theta1.data(0.2*end:end) - mean(theta1.data(0.2*end:end)), 40);
xlabel("Error [rad]"); ylabel("Number of occurrences [-]");
saveas(figure(6), 'images/hist_theta1.eps', 'epsc');

clf(figure(7)); figure(7); hold on; grid on;
histogram(dtheta1.data(0.2*end:end) - mean(dtheta1.data(0.2*end:end)), 40);
xlabel("Error [rad/s]"); ylabel("Number of occurrences [-]");
saveas(figure(7), 'images/hist_dtheta1.eps', 'epsc');

rmse_theta1 = rms(theta1.data - mean(theta1.data));
rmse_theta1_f = rms(x_filtered.data(:,1) - mean(x_filtered.data(:,1)));
rmse_dtheta1 = rms(dtheta1.data - mean(dtheta1.data))  ;
rmse_dtheta1_f = rms(x_filtered.data(:,2) - mean(x_filtered.data(:,2)));

rmse_theta2 = rms(theta2.data(0.8*end:end) - mean(theta2.data(0.8*end:end)))  ;
rmse_theta2_f = rms(x_filtered.data(0.8*end:end,3) - mean(x_filtered.data(0.8*end:end,3)));
rmse_dtheta2 = rms(dtheta2.data(0.8*end:end) - mean(dtheta2.data(0.8*end:end)))  ;
rmse_dtheta2_f = rms(x_filtered.data(0.8*end:end,4) - mean(x_filtered.data(0.8*end:end,4)));

