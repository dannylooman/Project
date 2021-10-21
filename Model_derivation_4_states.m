%% Danny Looman & George Vitanov
% Integration Project Rotational Pendulum
% Script inspired by the project of the course Modeling of Dynamical
% systems

%% INITIALIZE Workspace
clear all; clc;

% Variables for pendulum
syms theta_1(t) theta_2(t) L1 L2 m1 m2 g C1 b1 b2 ddth1 ddth2

% Variables for DC-motor
syms Km U_in x1 x2 x3 x4

%% ForceMatrix MassMatrix derivation
% Kinematics
pos = states2pos(theta_1, theta_2, L1, L2);
x_1 = pos.x_1; y_1 = pos.y_1; x_2 = pos.x_2; y_2 = pos.y_2;
clear pos

% Time derivatives
dx_1 = diff(x_1, t);
dx_2 = diff(x_2, t);
dy_1 = diff(y_1, t);
dy_2 = diff(y_2, t);
dtheta_1 = diff(theta_1, t);
dtheta_2 = diff(theta_2, t);
ddtheta_1 = diff(dtheta_1, t);
ddtheta_2 = diff(dtheta_2, t);

% ENERGY DEFINITIONS
% Potential energy
P = m1*g*C1*y_1 + m2*g*y_2;

% Kinetic energy
K_trans =  1/2*m1*C1^2*(dx_1^2 + dy_1^2) + 1/2*m2*(dx_2^2 + dy_2^2);
K_rot = 0;
K = K_trans + K_rot;

% Disapative energy
D = 0.5*b2*dtheta_2^2 + 0.5*b1*dtheta_1^2;  % Not used yet

% Apply Euler-Lagrange
L = simplify(K - P);
dL_theta_1  = diff(L,  theta_1(t));
dL_dtheta_1 = diff(L, dtheta_1(t));

dL_theta_2  = diff(L,  theta_2(t));
dL_dtheta_2 = diff(L, dtheta_2(t));

% equations of motion 
deq1 =  Km*U_in == diff(dL_dtheta_1, t) - dL_theta_1 + diff(D, dtheta_1(t));   % th1
deq2 =   0      == diff(dL_dtheta_2, t) - dL_theta_2 + diff(D, dtheta_2(t));   % th2

% Reformat equations of motion
var = [theta_1; theta_2];
leqs = [deq1; deq2];

%%
eqs = subs(subs(subs(subs(subs(subs(leqs,ddtheta_1,ddth1),ddtheta_2,ddth2),dtheta_1,x2),dtheta_2,x4),theta_1(t),x1),theta_2(t),x3);

%Solve algebraic equations to get \ddtheta_1 and \ddtheta2 separately
res = solve(eqs == [0;0],[ddth1 ddth2]); %the dynamics equations in the correct form

%% Function Definitions
function pos = states2pos(theta_1, theta_2, L1, L2)
    % Contains kinematics
    pos.x_1 = L1*sin(theta_1);
    pos.y_1 = L1*cos(theta_1);
    pos.x_2 = pos.x_1 + L2 * sin(theta_2 + theta_1);
    pos.y_2 = pos.y_1 + L2 * cos(theta_2 + theta_1);
end