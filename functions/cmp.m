function sys = cmp(id_sys)
    [A,B,C,D,T] = ssdata(id_sys);
    sys = ss(A,B,C,D,T);
end