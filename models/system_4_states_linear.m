function [A,B,C,D] = system_4_states_linear(a, b, c, d, Ts, model_first_link, model_second_link)
% Subsitutions made from nonlinfun value
%
% Parameters: bottom left submatrice of A
% input: no input is applied 

a_sub = [0, 0; a, b];
Y = model_second_link.A;
Y(2,2) = d;

A = [model_first_link.A, zeros(2); 
     a_sub, model_second_link.A];
     
B = [model_first_link.B; 0; c];

C = eye(4);
 
D = zeros(4, 1);
end