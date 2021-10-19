function [A,B,C,D] = system_3_states_linear(a, b, c, Ts, model_first_link, model_second_link)
% Subsitutions made from nonlinfun value
%
% Parameters: bottom left submatrice of A
% input: no input is applied 
     
A = [model_first_link.A, zeros(1, 2);
     0, 0, 1;
     a, b, c];
     
B = [model_first_link.B; zeros(2, 1)];

C = eye(3);
 
D = zeros(3, 1);
end