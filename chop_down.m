function ret = chop_down(x)
if abs(x) < 0.01
    ret = 0;
else
    ret = x;
end