% Symbolic variables x-5dim
clear all
syms x [4 1]
syms U_in

%% Parameters: %L1, L2, m_1, m_2, C1, b2, g, R_a, K_m ,L_a
hwinit

L1 = model.L1;
L2 = model.L2;
m1 = model.m1;
m2 = model.m2;
C1 = model.C1;
b2 = model.b2;
b1 = model.b2;
g = model.g;
Ra = model.Ra;
Km = model.Km;
La = model.La;
K = model.Km;

%vars:
% theta1 -x(1)
% omega1 -x(2)
% i      -x(3)
% theta2 -x(4)
% omega2 -x(5)

% Differential equations (dx/dt = f, and y = g)

f = [x(2);
     (Km*L2*U_in - L2*b1*x(2) + L2*b2*x(4) + L1*b2*x(4)*cos(x(3)) + L1*L2^2*m2*x(2)^2*sin(x(3)) + L1*L2^2*m2*x(4)^2*sin(x(3)) + L1*L2*g*m2*sin(x(1)) + L1^2*L2*m2*x(2)^2*cos(x(3))*sin(x(3)) - L1*L2*g*m2*sin(x(1) + x(3))*cos(x(3)) + 2*L1*L2^2*m2*x(2)*x(4)*sin(x(3)) + C1*L1*L2*g*m1*sin(x(1)))/(L2*m1*C1^2*L1^2 - L2*m2*L1^2*cos(x(3))^2 + L2*m2*L1^2)
     x(4);
     -(Km*L2^2*U_in*m2 - L2^2*b1*m2*x(2) + L1^2*b2*m2*x(4) + L2^2*b2*m2*x(4) - L1^2*L2*g*m2^2*sin(x(1) + x(3)) + L1*L2^2*g*m2^2*sin(x(1)) + L1*L2^3*m2^2*x(2)^2*sin(x(3)) + L1^3*L2*m2^2*x(2)^2*sin(x(3)) + L1*L2^3*m2^2*x(4)^2*sin(x(3)) + C1^2*L1^2*b2*m1*x(4) - L1*L2*b1*m2*x(2)*cos(x(3)) + 2*L1*L2*b2*m2*x(4)*cos(x(3)) + 2*L1^2*L2^2*m2^2*x(2)^2*cos(x(3))*sin(x(3)) + L1^2*L2^2*m2^2*x(4)^2*cos(x(3))*sin(x(3)) - L1*L2^2*g*m2^2*sin(x(1) + x(3))*cos(x(3)) + L1^2*L2*g*m2^2*cos(x(3))*sin(x(1)) + Km*L1*L2*U_in*m2*cos(x(3)) + 2*L1*L2^3*m2^2*x(2)*x(4)*sin(x(3)) + 2*L1^2*L2^2*m2^2*x(2)*x(4)*cos(x(3))*sin(x(3)) + C1^2*L1^3*L2*m1*m2*x(2)^2*sin(x(3)) + C1*L1*L2^2*g*m1*m2*sin(x(1)) - C1^2*L1^2*L2*g*m1*m2*sin(x(1) + x(3)) + C1*L1^2*L2*g*m1*m2*cos(x(3))*sin(x(1)))/(m1*C1^2*L1^2*L2^2*m2 - L1^2*L2^2*m2^2*cos(x(3))^2 + L1^2*L2^2*m2^2)
      ];

g = [x(1); x(2); x(3); x(4)];
%% Linearizing the Diff.eq.-s around x0 = 0,0,0,0,0

subs_vec_up_up     = [0  0 0  0 0]; %x(1)-x(4) U_in
subs_vec_down_down = [pi 0 0  0 0]; %x(1)-x(4) U_in
subs_vec_up_down   = [0  0 pi 0 0]; %x(1)-x(4) U_in

sys_up_up = get_ABCD(f,g,x,U_in,subs_vec_up_up)
sys_down_down = get_ABCD(f,g,x,U_in,subs_vec_down_down)
sys_up_down = get_ABCD(f,g,x,U_in,subs_vec_up_down)

stop
%%
h=0.01;
sys_up_up_d = c2d(sys_up_up,h); % discrete time sys
sys_down_down_d = c2d(sys_down_down,h); % discrete time sys

%% Functions
function sys = get_ABCD(f,g,x,U_in,subs_vec)
A = eval(subs_param_x(jacobian(f,x),x,U_in,subs_vec));
B = eval(subs_param_x(jacobian(f,U_in),x,U_in,subs_vec));
C = eval(subs_param_x(jacobian(g,x),x,U_in,subs_vec));
D = eval(subs_param_x(jacobian(g,U_in),x,U_in,subs_vec));

sys = ss(A,B,C,D);
end

%Substitute x,and U_in around 0
function M = subs_param_x(J,x,U_in,subs_vec)
M = subs(subs(subs(subs(subs(J,x(1),subs_vec(1)),x(2),subs_vec(2)),x(3),subs_vec(3)),x(4),subs_vec(4)),U_in,subs_vec(5));
end
