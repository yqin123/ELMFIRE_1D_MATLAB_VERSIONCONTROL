function y_out=custom_interpolation(x_in,y_in,x_out)
% x_in=C(2,end:-1:2);y_in=C(1,end:-1:2);x_out=60;
if(x_out<max(x_in))
    x_diff=(x_out-x_in);
    loc = find(x_diff(1:end-1).*x_diff(2:end)<=0);

    if(~isempty(loc) && max(loc)<length(x_in))
        loc=loc(1);
        y_out = (y_in(loc+1)-y_in(loc))/(x_in(loc+1)-x_in(loc))*(x_out-x_in(loc))+y_in(loc);
    else
        y_out = (y_in(end)-y_in(end-1))/(x_in(end)-x_in(end-1))*(x_out-x_in(end))+y_in(end);
    end
elseif(x_out==max(x_in))
    y_out=y_in(x_in==max(x_in));
    y_out = y_out(1);
else
    y_out=nan;
end

end