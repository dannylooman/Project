%% Danny Looman & George Vitanov
% Integration Project Rotational Pendulum
% Script inspired by the project of the course Modeling of Dynamical
% systems

%% INITIALIZE Workspace
clear; clc;

% Variables for pendulum
syms theta_1(t) theta_2(t) I(t) L1 L2 m_1 m_2 g C1 b2

% Variables for DC-motor
syms R_a K_r K_t L_a U_in

%% ForceMatrix MassMatrix derivation
% Kinematics
x_1 = L1*sin(theta_1);
y_1 = L1*cos(theta_1);
x_2 = x_1 + L2 * sin(theta_2 + theta_1);
y_2 = y_1 + L2 * cos(theta_2 + theta_1);

% Time derivatives
dx_1 = diff(x_1, t);
dx_2 = diff(x_2, t);
dy_1 = diff(y_1, t);
dy_2 = diff(y_2, t);
dtheta_1 = diff(theta_1, t);
dtheta_2 = diff(theta_2, t);

% ENERGY DEFINITIONS
% Potential energy
P = m_1 * g * C1 * y_1 + m_2 * g * y_2;

% Kinetic energy
K_trans =  0.5*m_1*(C1 * dx_1^2 + C1 * dy_1^2) + 0.5*m_2*(dx_2^2 + dy_2^2);
K_rot = 0;
K = K_trans + K_rot;

% Disapative energy
D = 1/2 * b2 * dtheta_2^2;  % Not used yet

% Apply Euler-Lagrange
L = simplify(K - P);
dL_theta_1 = diff(L, theta_1);
dL_dtheta_1 = diff(L, dtheta_1);

dL_theta_2 = diff(L, theta_2);
dL_dtheta_2 = diff(L, dtheta_2);

% equations of motion 
deq1 = diff(dL_dtheta_1, t) - dL_theta_1 + diff(D, dtheta_1);   % th1
deq2 = diff(dL_dtheta_2, t) - dL_theta_2 + diff(D, dtheta_2);   % th2
deq3 = R_a*I + L_a*diff(I(t), t) + K_r * dtheta_1;              % I, From: https://ctms.engin.umich.edu/CTMS/index.php?example=MotorSpeed&section=SystemModeling

% Reformat equations of motion
var = [theta_1; theta_2; I];
leqs = [deq1 == K_t * I; deq2 == 0; deq3 == U_in];

[eqs, vars] = reduceDifferentialOrder(leqs, var);
[MassMatrix, ForceMatrix] = massMatrixForm(eqs, vars);

MassMatrix = simplify(MassMatrix);
ForceMatrix = simplify(ForceMatrix);

save('saved_data\Equations_and_vars.mat', 'MassMatrix', 'ForceMatrix', 'vars')

%%
MassMatrix

ForceMatrix
