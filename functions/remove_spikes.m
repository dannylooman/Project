function [y_spikefree] = remove_spikes(y, smoothing_length)
%REMOVE_SPIKES Summary of this function goes here
%   y - inputsequence of data with spikes that needs to be removed
y_spikefree = y;

% Use as a thresshold the derivative
N = length(y);
tresshold_spike = diff(y);


% Check for spikes over input signal
index = [];
for i = 1:N-1
    if abs(tresshold_spike(i)) > 0.5
        index = [index i];       
    end
end

% if the end of the peak is in the dataset, length(index) must be even
for i = 1:1:length(index)
    window_max = index(i) + smoothing_length;
    window_min = index(i) - smoothing_length;
    
    if index(i) + smoothing_length > N
        window_max = N;
    elseif index(i) - smoothing_length < 1
        window_min = 1;
    end
    
    x = [window_min, window_max];
    v = [y(window_min), y(window_max)];
    xq = window_min : window_max;
    y_spikefree(xq) = interp1(x, v, xq);
end


end

