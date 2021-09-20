clear; clc; close all;

load("saved_data\07-Sep-2021 11_42_45.mat");
dt = theta1.time(2) - theta1.time(1);
theta1 = conv_theta(theta1);
theta2 = conv_theta(theta2);

figure(1); hold on;
subplot(2,2,1); hold on;
title("Angles"); xlabel("Time [s]"); ylabel("Angle [rad]");
plot(theta1.time, theta1.angle)
plot(theta2.time, theta2.angle)
legend("\theta_1", "\theta_2")

subplot(2,2,2); hold on;
title("Input signal"); xlabel("Time [s]"); ylabel("U_{in} [V]");
plot(input.time, input.data);

subplot(2,2,3); hold on;
title("\theta_1 dot");
xlabel("Time [s]");
ylabel("Angular velocity [rad/s]");
plot(diff(theta1.angle)/dt)
plot(theta1.dot)
legend("Euler", "Smoothed");

subplot(2,2,4); hold on;
title("\theta_2 dot");
xlabel("Time [s]");
ylabel("Angular velocity [rad/s]");
plot(diff(theta2.angle)/dt)
plot(theta2.dot)
legend("Euler", "Smoothed");