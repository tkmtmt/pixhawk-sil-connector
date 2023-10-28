% rcFlightSimulator - RCフライトシミュレータ
% 
% Other m-files required: joystickCalib.m
% Subfunctions: stab2bodyInertia.m
% MAT-files required: Aero.mat, InterLinkCalib.mat, thrust.mat
% See also: 
% Author: 冨田　匠
% Work address
% email: tomita.takumi@outlook.jp
% Website: 
% November 2022; Last revision: 22-Nov-2022

clc;
clear all;
close all;

%% 環境諸元
Env.rho = 1.164;      % density[kg/m^3]
Env.g = 9.81;        % gravity[m/s^2]

% 定常風速(NED座標)
Env.Uw = 0;   % [m/s]
Env.Vw = 0;
Env.Ww = 0;
Env.Pw = 0;   % [rad/s]
Env.Qw = 0;
Env.Rw = 0;

Env.Ze0 = -2;

%% 機体諸元
Spec.m = 7.574;   % mass[kg]
Spec.b = 6.5;      % span[m]
Spec.c = 0.346623;     % mean chord[m]
Spec.S = 2.242;      % wing area[m^2]

% 慣性モーメント(安定軸)[kg m^2]
Stab.VInf = 10.07930;
Stab.alpha0 = deg2rad(-2.98864);
Stab.theta0 = 0;
Stab.Ixx = 6.415;
Stab.Iyy = 1.296;
Stab.Izz = 7.693;
Stab.Ixz = -0.1176;
Stab.J = [Stab.Ixx, 0,        Stab.Ixz;
          0,        Stab.Iyy, 0;
          Stab.Ixz, 0,        Stab.Izz];    % inertia

% 機体軸
Body.VInf = Stab.VInf;
Body.alpha0 = Stab.alpha0;
Body.theta0 = Body.alpha0;
Body.J = stab2bodyInertia(Stab.J,Stab.alpha0);
Body.Ixx = Body.J(1,1);
Body.Iyy = Body.J(2,2);
Body.Izz = Body.J(3,3);
Body.Ixz = Body.J(1,3);

% 無次元安定微係数(安定軸)
% Stab.Cxu=   -0.18687;
% Stab.Cxa=     0.46093;
% Stab.Czu=    -0.010148;
% Stab.CLa=      5.8403;
Stab.CLq=      8.6258;
% Stab.Cmu=   -0.0062573;
% Stab.Cma=     -1.1271;
Stab.Cmq=     -16.219;
Stab.Cyb=    -0.16851;
Stab.Cyp=   -0.0058814;
Stab.Cyr=     0.082328;
Stab.Clb=  -0.0058521;
Stab.Clp=    -0.72535;
Stab.Clr=     0.14054;
Stab.Cnb=    0.036708;
Stab.Cnp=    -0.073979;
Stab.Cnr=   -0.00031069;

Stab.Cxde=   0.0025979;
% Stab.Cyde= 0;
Stab.Czde=    -0.44128;
% Stab.Clde=  0;
Stab.Cmde=     -1.7262 *2;
% Stab.Cnde=  0;

Stab.Cxda = 0;
Stab.Cyda = 0;
Stab.Czda = 0;
Stab.Clda = 0.139 * 3;
Stab.Cmda = 0;
Stab.Cnda = 0.0005;

Stab.Cxdr = 0;
Stab.Cydr = 0.116;
Stab.Czdr = 0;
Stab.Cldr = 0.007;
Stab.Cmdr = 0;
Stab.Cndr = -0.126;

%% 安定微係数の座標変換(機体軸)
% z
Body.CLq = Stab.CLq*cos(Stab.alpha0);
% m
Body.Cmq = Stab.Cmq;
% y
Body.Cyb = Stab.Cyb;
Body.Cyp = Stab.Cyp*cos(Stab.alpha0) - Stab.Cyr*sin(Stab.alpha0);
Body.Cyr = Stab.Cyp*sin(Stab.alpha0) + Stab.Cyr*cos(Stab.alpha0);
% l
Body.Clb = Stab.Clb*cos(Stab.alpha0) - Stab.Cnb*sin(Stab.alpha0);
Body.Clp = Stab.Clp*cos(Stab.alpha0)^2 ...
         + Stab.Cnr*sin(Stab.alpha0)^2 ...
         - (Stab.Clr + Stab.Cnp)*sin(Stab.alpha0)*cos(Stab.alpha0);
Body.Clr = Stab.Clr*cos(Stab.alpha0)^2 ...
         - Stab.Cnp*sin(Stab.alpha0)^2 ...
         + (Stab.Clp - Stab.Cnr)*sin(Stab.alpha0)*cos(Stab.alpha0);
% n
Body.Cnb = Stab.Clb*sin(Stab.alpha0) + Stab.Cnb*cos(Stab.alpha0);
Body.Cnp = Stab.Cnp*cos(Stab.alpha0)^2 ...
         - Stab.Clr*sin(Stab.alpha0)^2 ...
         + (Stab.Clp - Stab.Cnr)*sin(Stab.alpha0)*cos(Stab.alpha0);
Body.Cnr = Stab.Cnr*cos(Stab.alpha0)^2 ...
         + Stab.Clp*sin(Stab.alpha0)^2 ...
         + (Stab.Clr + Stab.Cnp)*sin(Stab.alpha0)*cos(Stab.alpha0);
% elevator
Body.Cxde = Stab.Cxde*cos(Stab.alpha0) - Stab.Czde*sin(Stab.alpha0);
% Body.Cyde = Stab.Cyde;
Body.Czde = Stab.Cxde*sin(Stab.alpha0) + Stab.Czde*cos(Stab.alpha0);
Body.Cmde = Stab.Cmde;
% ailron
Body.Cxda = Stab.Cxda;
Body.Cyda = Stab.Cyda;
Body.Czda = Stab.Czda;
Body.Clda = Stab.Clda*cos(Stab.alpha0) - Stab.Cnda*sin(Stab.alpha0);
Body.Cmda = Stab.Cmda;
Body.Cnda = Stab.Clda*sin(Stab.alpha0) + Stab.Cnda*cos(Stab.alpha0);
% rudder
Body.Cxdr = Stab.Cxdr;
Body.Cydr = Stab.Cydr;
Body.Czdr = Stab.Czdr;
Body.Cldr = Stab.Cldr*cos(Stab.alpha0) - Stab.Cndr*sin(Stab.alpha0);
Body.Cmdr = Stab.Cmdr;
Body.Cndr = Stab.Cldr*sin(Stab.alpha0) + Stab.Cndr*cos(Stab.alpha0);

% CL,CD,Cmテーブル
load Aero.mat

% 推力テーブル
load thrust.mat

%% 初期条件
%初期位置(慣性座標系)
Xe0 = 0; % [m]
Ye0 = 0;
Ze0 = Env.Ze0;
%初期速度(機体座標系)
U0 = 1e-3;
V0 = 1e-3;
W0 = 1e-3;

%初期角速度
P0 = 1e-3; % [rad/s]
Q0 = 1e-3;
R0 = 1e-3;
%初期オイラー角(3-2-1系)
phi0 = 1e-3;   % [rad]
theta0 = 1e-3;
psi0 = 1e-3;
% 状態量ベクトル
X0 = [Xe0; Ye0; Ze0; U0; V0; W0; P0; Q0; R0; phi0; theta0; psi0];


%% プロポ設定
% futaba
minStickPos = -0.6562;  % スティック最小位置
maxStickPos = 0.6561;   % スティック最大位置
maxAileronAngle = 20;   % deg
maxElevatorAngle = 7;   % deg
maxRudderAngle = 5;   % deg

% interlink
load('InterLinkCalib.mat')

%% シミュレーション設定
dt = 0.01;
tend = Inf;

% アニメーションオブジェクト初期位置
initX = [Xe0, Ye0, Ze0; % body
         0 0 0; % prop
         0 0 0; % rudder
         0 0 0; % elevator
         0 0 0; % left aileron
         0 0 0; % right aileron
         0 0 0; % flaps
         0 0 0; % nose wheel strut
         0 0 0; % nose wheel
         0 0 0; % left wheel
         0 0 0]; % right wheel
% アニメーションオブジェクト初期回転
initR = zeros(11,3);

% シミュレーション
% simout = sim('rcFlightSimulatorSimulink.slx');
