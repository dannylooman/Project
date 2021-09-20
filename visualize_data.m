clear; clc; close all;
%%
load("saved_data\15-Sep-2021 09_50_03-freq_sweep_stationary_second_link.mat");
%%
dt = theta1.time(2) - theta1.time(1);
theta1 = conv_theta(theta1);
theta2 = conv_theta(theta2);

figure(1); hold on;
subplot(2,2,1); hold on;
title("Angles"); xlabel("Time [s]"); ylabel("Angle [rad]");
plot(theta1.time, theta1.Data(:,1))
plot(theta2.time, theta2.Data(:,1))
legend("\theta_1", "\theta_2")

subplot(2,2,2); hold on;
title("Input signal"); xlabel("Time [s]"); ylabel("U_{in} [V]");
plot(input.time, input.data);

subplot(2,2,3); hold on;
title("\theta_1 dot");
xlabel("Time [s]");
ylabel("Angular velocity [rad/s]");
plot(diff(theta1.Data(:,1))/dt)
plot(theta1.Data(:,2))
legend("Euler", "Smoothed");

subplot(2,2,4); hold on;
title("\theta_2 dot");
xlabel("Time [s]");
ylabel("Angular velocity [rad/s]");
plot(diff(theta2.Data(:,1))/dt)
plot(theta2.Data(:,2))
legend("Euler", "Smoothed");