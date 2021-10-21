clear; clc;

%%
load("saved_data\20-Oct-2021 10_37_42-results_downward_stabelizing.mat");
control_objective = theta1 - pi + theta2;

clf(figure(1)); figure(1); hold on; grid on;
plot(theta1 - pi, '--', 'linewidth', 2)
plot(control_objective, 'linewidth', 2)

xlabel("time [s]"); ylabel("Angular Position [rad]");
legend("\theta_1","\theta_1 + \theta_2");
saveas(figure(1), 'images/control_downward_a_0.eps', 'epsc');


%%
load("saved_data\19-Oct-2021 09_44_26-stabelizing_downward.mat");

control_objective = theta1.data(:,1) + theta2.data(2:end) - pi;
clf(figure(2)); figure(2); hold on; grid on;
plot(theta1.time, theta1.data(:,1) - pi, '--', 'linewidth', 2)
plot(theta1.time, control_objective, 'linewidth', 2)

xlabel("time [s]"); ylabel("Angular Position [rad]");
legend("\theta_1","\theta_1 + \theta_2");
saveas(figure(2), 'images/control_downward.eps', 'epsc');