syms x [5 1]
syms U_in

%%
% Parameters: %L1, L2, m_1, m_2, C1, b2, g, R_a, K_m ,L_a
load('saved_data/model_parameters.mat')
%vars:
%x(1) - theta1
%x(2) - theta2
%x(3) - i
%x(4) - omega1
%x(5) - omega2

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


f = [x(4);
      x(5);
      -(K_m*x(4) - U_in + R_a*x(3))/L_a;
      (L1*L2*m_2*sin(x(2))*x(5)^2 + 2*L1*L2*m_2*x(4)*sin(x(2))*x(5) + K_m*x(3) + L2*g*m_2*sin(x(1) + x(2)) + L1*g*m_2*sin(x(1)) + C1*L1*g*m_1*sin(x(1)))/(m_1*C1^2*L1^2 - m_2*L1^2*cos(x(2))^2 + m_2*L1^2) + ((L2 + L1*cos(x(2)))*(L1*L2*m_2*sin(x(2))*x(4)^2 + b2*x(5) - L2*g*m_2*sin(x(1) + x(2))))/(L2*m_1*C1^2*L1^2 - L2*m_2*L1^2*cos(x(2))^2 + L2*m_2*L1^2);
      - ((L2 + L1*cos(x(2)))*(L1*L2*m_2*sin(x(2))*x(5)^2 + 2*L1*L2*m_2*x(4)*sin(x(2))*x(5) + K_m*x(3) + L2*g*m_2*sin(x(1) + x(2)) + L1*g*m_2*sin(x(1)) + C1*L1*g*m_1*sin(x(1))))/(L2*m_1*C1^2*L1^2 - L2*m_2*L1^2*cos(x(2))^2 + L2*m_2*L1^2) - ((L1*L2*m_2*sin(x(2))*x(4)^2 + b2*x(5) - L2*g*m_2*sin(x(1) + x(2)))*(m_1*C1^2*L1^2 + m_2*L1^2 + 2*m_2*cos(x(2))*L1*L2 + m_2*L2^2))/(L2*m_2*(L2*m_1*C1^2*L1^2 - L2*m_2*L1^2*cos(x(2))^2 + L2*m_2*L1^2))
      ];

g = [x(1); x(2); x(4); x(5)];
%%

A = eval(subs_param_x(jacobian(f,x),x,U_in));
B = eval(subs_param_x(jacobian(f,U_in),x,U_in));
C = eval(subs_param_x(jacobian(g,x),x,U_in));
D = eval(subs_param_x(jacobian(g,U_in),x,U_in));
 
sys = ss(A,B,C,D);
sys_d = c2d(sys,h);

%%
function M = subs_param_x(J,x,U_in)
M = subs(subs(subs(subs(subs(subs(J,x(1),0),x(2),0),x(3),0),x(4),0),x(5),0),U_in,0);
end
