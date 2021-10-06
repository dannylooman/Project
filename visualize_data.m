clear; clc; close all;
hwinit;
load("saved_data\06-Oct-2021 09_44_13-first_link_100hz.mat");

dt = theta1.time(2) - theta1.time(1);

theta1_conv = conv_theta(theta1);
theta2_conv = conv_theta(theta2);

% Theta angels
figure(1); hold on;
subplot(2,2,1); hold on;
title("Angles"); xlabel("Time [s]"); ylabel("Angle [rad]");
plot(theta1.time, theta1.Data(:,1))
plot(theta2.time, theta2.Data(:,1))
legend("\theta_1", "\theta_2")

% Input signal
subplot(2,2,2); hold on;
title("Input signal"); xlabel("Time [s]"); ylabel("U_{in} [V]");
plot(input.time, input.data);

% Theta1 dot
subplot(2,2,3); hold on;
title("\theta_1 dot");
xlabel("Time [s]");
ylabel("Angular velocity [rad/s]");
plot(dtheta1)
plot(theta1_conv.time, theta1_conv.Data(:,2))
legend("live differentation", "conv function");

% Theta2 dot
subplot(2,2,4); hold on;
title("\theta_2 dot");
xlabel("Time [s]");
ylabel("Angular velocity [rad/s]");
plot(dtheta2)
plot(theta2_conv.time, theta2_conv.Data(:,2))
legend("live differentation", "conv function");