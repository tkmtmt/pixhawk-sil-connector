function Jb = stab2bodyInertia(Js, alpha0)
% stab2bodyInertia - 慣性テンソルの座標変換(安定軸→機体軸)
% 
% Syntax:  Jb = stab2bodyInertia(Js, alpha0)
%
% Inputs:
%    Js - 慣性テンソル(安定軸)
%    alpha0 - 迎え角[rad]
%
% Outputs:
%    Jb - 慣性テンソル(安定軸)
%
% Example: 
%    
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
% See also: none
%
% Author: 冨田　匠
% Work address
% email: 
% Website: 
% November 2022; Last revision: 18-Nov-2022

Ry = [cos(alpha0), 0, -sin(alpha0);
      0,           1, 0;
      sin(alpha0), 0, cos(alpha0)];
Jb = Ry'*Js*Ry;
