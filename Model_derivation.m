%% Danny Looman & George Vitanov
% Integration Project Rotational Pendulum
% Script inspired by the project of the course Modeling of Dynamical
% systems

%% INITIALIZE Workspace
clear; clc;

% Variables for pendulum
syms theta_1(t) theta_2(t) I(t) L1 L2 m_1 m_2 g C1 b2

% Variables for DC-motor
syms R_a K_m L_a U_in

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

% ENERGY DEFINITIONS
% Potential energy
P = m_1*g*C1*y_1 + m_2*g*y_2;

% Kinetic energy
K_trans =  1/2*m_1*C1^2*(dx_1^2 + dy_1^2) + 1/2*m_2*(dx_2^2 + dy_2^2);
K_rot = 0;
K = K_trans + K_rot;

% Disapative energy
D = 1/2*b2*dtheta_2^2;  % Not used yet

% Apply Euler-Lagrange
L = simplify(K - P);
dL_theta_1  = diff(L,  theta_1(t));
dL_dtheta_1 = diff(L, dtheta_1(t));

dL_theta_2  = diff(L,  theta_2(t));
dL_dtheta_2 = diff(L, dtheta_2(t));

% equations of motion 
deq1 =  K_m*I == diff(dL_dtheta_1, t) - dL_theta_1 + diff(D, dtheta_1(t));   % th1
deq2 =   0    == diff(dL_dtheta_2, t) - dL_theta_2 + diff(D, dtheta_2(t));   % th2
deq3 =   U_in == R_a*I + L_a*diff(I, t) + K_m*dtheta_1;              % I, From: https://ctms.engin.umich.edu/CTMS/index.php?example=MotorSpeed&section=SystemModeling

% Reformat equations of motion
var = [theta_1; theta_2; I];
leqs = [deq1; deq2; deq3];

[eqs, vars] = reduceDifferentialOrder(leqs, var);
[MassMatrix, ForceMatrix] = massMatrixForm(eqs, vars);

MassMatrix  = simplify(MassMatrix);
ForceMatrix = simplify(ForceMatrix);

save('saved_data\Equations_and_vars.mat', 'MassMatrix', 'ForceMatrix', 'eqs', 'vars')

%% Generate ode function used for identification
% nonlinfun has the form x_dot = f(t, x)
nonlinfun = inv(MassMatrix) * ForceMatrix;

nonlinfun = subs(nonlinfun, [vars(1), vars(2), vars(3), vars(4), vars(5)], [sym('x_1'), sym('x_2'), sym('x_3'), sym('x_4'), sym('x_5')])


%% Subsitute constants in system
p.L1 = 0.10;   % Length link 1 [m]
p.L2 = 0.07;   % Length link 2 [m]
p.m_1 = 0.10;  % Mass link 1 [kg]
p.m_2 = 0.05;  % Mass link 2 [kg]  
p.C1 = 0.80;   % Length factor of center off mass divided by L1 [-]
p.b2 = 0.0001;  % rotational friction constant [-]
p.g = 9.81;    % Gravity constant [m/s^2]

% DC-motor varaibles
p.R_a = 0.5; % Ohm
p.K_m = 0.5; 
p.L_a = 0.1; %H

Mm = subs(MassMatrix,  [L1 L2 m_1 m_2 C1 b2 g R_a K_m L_a], [p.L1 p.L2 p.m_1 p.m_2 p.C1 p.b2 p.g p.R_a p.K_m p.L_a]);
Ff = subs(ForceMatrix, [L1 L2 m_1 m_2 C1 b2 g R_a K_m L_a], [p.L1 p.L2 p.m_1 p.m_2 p.C1 p.b2 p.g p.R_a p.K_m p.L_a]);

MM = odeFunction(Mm, vars, U_in);
FF = odeFunction(Ff, vars, U_in);

%% Use model for simulation
dt = 0.01; T_end = 20;
time_vec = (0 : dt : T_end)';
N = length(time_vec);
U_in_ =  0*ones(N, 1);
opts = odeset('Mass', MM);
[~, x] = ode45(FF, time_vec, [0.2, 0.5, 0, 0, 0], opts, U_in_(1));

pos = states2pos(x(:, 1), x(:, 2), p.L1, p.L2);

%% Animate simulation
clear movieVector
figure(1)
for i = 1:5:N
    clf; hold on;
    ylim([-0.25 0.25])
    xlim([-0.25 0.25])
    daspect([1 1 1])
    grid on;
    set(gca,'xtick',[-0.25:0.05:0.25])
    set(gca,'ytick',[-0.25:0.05:0.25])
    
    plot([pos.x_1(i) 0], [pos.y_1(i) 0], 'LineWidth', 8, 'Color', [64/255 64/255 64/255]) % link 1
    plot([pos.x_2(i) pos.x_1(i)], [pos.y_2(i) pos.y_1(i)], 'LineWidth', 3, 'Color', [64/255 64/255 64/255]) % link 2
    
    % point masses visualisation
    plot(pos.x_1(i), pos.y_1(i), '.', 'Color', [64/255 64/255 64/255], 'MarkerSize', 40)
    plot(pos.x_2(i), pos.y_2(i), '.', 'Color', [64/255 64/255 64/255], 'MarkerSize', 60)
    
    plot(0, 0, '.', 'Color', [64/255 64/255 64/255], 'MarkerSize', 80)
    plot(0, 0, '.', 'Color', [255/255 255/255 255/255], 'MarkerSize', 70)
    plot(0, 0, '.', 'Color', [64/255 64/255 64/255], 'MarkerSize', 30)
    
    title(strcat("Simulation Time: ", num2str(time_vec(i), 2), " s"))
    xlabel('x (m)')
    ylabel('y (m)')
    
    movieVector(round(i/5) + 1) = getframe(gcf);
	drawnow
end

% export video
if 0
    myWriter = VideoWriter('C:\Users\Danny\Desktop\sim_hybrid.mp4', 'MPEG-4');
    myWriter.FrameRate = 20;
    open(myWriter);
    writeVideo(myWriter, movieVector);
    close(myWriter);
end


%% Function Definitions
function pos = states2pos(theta_1, theta_2, L1, L2)
    % Contains kinematics
    pos.x_1 = L1*sin(theta_1);
    pos.y_1 = L1*cos(theta_1);
    pos.x_2 = pos.x_1 + L2 * sin(theta_2 + theta_1);
    pos.y_2 = pos.y_1 + L2 * cos(theta_2 + theta_1);
end