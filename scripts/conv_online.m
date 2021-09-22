function y = conv_online(u)
persistent c1 c2 corr
        
if isempty(c1)
    c1 = 1;
    c2 = 1;
    corr = 0;
    return
end


if u(end)-u(end-1) > 1 || c1 > 1                        % when detecting a jump bigger than 1
    if (u(end-c1) - u(end) < -5.6)                      % check if we jumped at least 5.6 in value
        corr = corr - 2*pi;                             % if yes correct with 2 pi
        c1 = 1;                                         % reset counter
    else
        c1 = c1+1;                                      % if jump is smaller than 5.6 increment counter
        if c1 > 5                                       % if in 5 samples we have not made a sufficiently big jump, reset counter
            c1 = 1;
        end
    end
elseif u(end)-u(end-1) < -1 || c2 > 1
    if (u(end-c2) - u(end) > 5.6)
        corr = corr + 2*pi;
        c2 = 1;
    else
        c2 = c2+1;
        if c2 > 5
            c2 = 1;
        end
    end
end

y=u+corr;
