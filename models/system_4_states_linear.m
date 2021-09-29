function [A,B,C,D] = system_4_states_linear(a, b, c, d, Ts, model_first_link, model_second_link)
% Subsitutions made from nonlinfun value
%
% Parameters: bottom left submatrice of A
% input: no input is applied 

a_sub = [a, b; c, d];
A = [model_first_link.A, zeros(2);
     a_sub, model_second_link.A];
     
B = [model_first_link.B; zeros(2, 1)];

C = eye(4);
 
D = zeros(4, 1);
end