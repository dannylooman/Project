% Symbolic variables x-5dim
syms x [5 1]
syms U_in

%% Parameters: %L1, L2, m_1, m_2, C1, b2, g, R_a, K_m ,L_a
load('saved_data/model_parameters.mat') % Load the model parameters <-- These are not final!

L1 = model.L1;
L2 = model.L2;
m_1 = model.m1;
m_2 = model.m2;
C1 = 1;
b2 = model.b2;
g = model.g;
R_a = model.Ra;
K_m = model.Km;
L_a = model.La;

%vars:
%x(1) - theta1
%x(2) - theta2
%x(3) - i
%x(4) - omega1
%x(5) - omega2

% Differential equations (dx/dt = f, and y = g)
f = [x(4);
      x(5);
      -(K_m*x(4) - U_in + R_a*x(3))/L_a;
      (L1*L2*m_2*sin(x(2))*x(5)^2 + 2*L1*L2*m_2*x(4)*sin(x(2))*x(5) + K_m*x(3) + L2*g*m_2*sin(x(1) + x(2)) + L1*g*m_2*sin(x(1)) + C1*L1*g*m_1*sin(x(1)))/(m_1*C1^2*L1^2 - m_2*L1^2*cos(x(2))^2 + m_2*L1^2) + ((L2 + L1*cos(x(2)))*(L1*L2*m_2*sin(x(2))*x(4)^2 + b2*x(5) - L2*g*m_2*sin(x(1) + x(2))))/(L2*m_1*C1^2*L1^2 - L2*m_2*L1^2*cos(x(2))^2 + L2*m_2*L1^2);
      - ((L2 + L1*cos(x(2)))*(L1*L2*m_2*sin(x(2))*x(5)^2 + 2*L1*L2*m_2*x(4)*sin(x(2))*x(5) + K_m*x(3) + L2*g*m_2*sin(x(1) + x(2)) + L1*g*m_2*sin(x(1)) + C1*L1*g*m_1*sin(x(1))))/(L2*m_1*C1^2*L1^2 - L2*m_2*L1^2*cos(x(2))^2 + L2*m_2*L1^2) - ((L1*L2*m_2*sin(x(2))*x(4)^2 + b2*x(5) - L2*g*m_2*sin(x(1) + x(2)))*(m_1*C1^2*L1^2 + m_2*L1^2 + 2*m_2*cos(x(2))*L1*L2 + m_2*L2^2))/(L2*m_2*(L2*m_1*C1^2*L1^2 - L2*m_2*L1^2*cos(x(2))^2 + L2*m_2*L1^2))
      ];

g = [x(1); x(2); x(4); x(5)];
%% Linearizing the Diff.eq.-s around x0 = 0,0,0,0,0

A = eval(subs_param_x(jacobian(f,x),x,U_in));
B = eval(subs_param_x(jacobian(f,U_in),x,U_in));
C = eval(subs_param_x(jacobian(g,x),x,U_in));
D = eval(subs_param_x(jacobian(g,U_in),x,U_in));
 
sys = ss(A,B,C,D);
sys_d = c2d(sys,h); % discrete time sys

[Ad,Bd,Cd,Dd,Ts]=ssdata(sys_d);
%% LQR control

Q = zeros(5);
Q(1:2,1:2)=ones(2)*1; % Our cost is (x1+x2)^2*1
Q(1,1)=1.2;           % Add little extra cost for x1^2 -> to go back to origin faster!
R = 1;                % Input cost is i^2*1
[K,~,~]=lqr(sys_d,Q,R,[]); % calc. K vector

sys_cl = ss(Ad-Bd*K,Bd,Cd,Dd,Ts); % create state feedbacked sys
% Simulate system for initial perturbation

t=0:1/1000:2;   % 2 sec horizon
u=0*t;          % no input (system already has feedback!)
x0 = [-0.2,0.1,0,0,0];  % slight initial deviation
y = lsim(sys_cl,u,t,x0);
plot(t,y(:,1)+y(:,2))   % Plot x1+x2 -> we can see system stabilizese!
hold
plot(t,y(:,1))
%% Functions

%Substitute x,and U_in around 0
function M = subs_param_x(J,x,U_in)
M = subs(subs(subs(subs(subs(subs(J,x(1),0),x(2),0),x(3),0),x(4),0),x(5),0),U_in,0);
end
