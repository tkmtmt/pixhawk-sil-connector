% joystickキャリブレーション

% interlinkdx
% aileron data4
% elavator data2
% throttle data5
% rudder data1
% switch f button 8and9
%   up button9=1
%   mid button8=0 bottton9=0
%   down button8=1
% switch b button 2and3
%   up button2=1
%   mid button2=0 bottton3=0
%   down button3=1

plot(out.simout.Data)
legend

% aileron min midle max
idx = [4,2,5,1];
Stick.Min = min(out.simout.Data(:,idx));
Stick.Max = max(out.simout.Data(:,idx));
band = (Stick.Max-Stick.Min)/2;
Stick.Mid = Stick.Min+band;

plot(out.simout.Time, out.simout.Data);

min(out.simout.Data(:,1:4))
max(out.simout.Data(:,1:4))
