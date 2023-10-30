# memo
## 概要
px4のSITLを用いてミッションの確認やアルゴリズムの確認を行いたい。  
でもpx4で対応しているSITLシミュレータ(例えばgazeboとか)は中の物理演算がどんな仕組みになっているかわかりにくいし、好きなモデルや空力係数でシミュレーションするためにはどうしたらよいかわからない。  
そこでシミュレータはSimulinkで作ることにして、px4とSimulinkを接続してSITLできる環境を整えよう。  
そうすれば、航空機のモデルは任意に作ることができるし、風等の環境だって好きにいじることができるであろう。  
いかにSimulink環境とPX4環境の構築方法を示す。

## 環境構築
### MATLAB/Simulink環境を構築する  
1. MATLAB/Simulinkをインストールする。  
https://jp.mathworks.com/products/matlab.html
1. mexファイルを作成する。  
    1. include.zipを解凍する。  
    1. make.mを実行する。(1回だけでOK)  
    memo:  
    コンパイラの確認。  
        ```
        mex -setup c++
        ```

### Windows Subsystem for Linuxを導入する  
PX4Toolchainを入れるための前準備。  
PX4ToolchainはWindowsに直接入れてもいいが、Ubuntuに入れたほうがPX4のポテンシャルをフルに発揮できるし、VSCodeでデバックできる環境が用意されているので、ここではUbuntuに入れることを想定してWSL2環境を構築する。

手動インストール手順(Microsoft):[以前のバージョンの WSL の手動インストール手順](https://learn.microsoft.com/ja-jp/windows/wsl/install-manual)  
自動インストール手順(Microsoft):[WSL を使用して Windows に Linux をインストールする方法](https://learn.microsoft.com/ja-jp/windows/wsl/install)

1. Windowsバージョン確認  
Win+R→winverでWindowsOSビルド番号を確認して、19041以上であることを確認する。それ以下なら手動インストール手順を参照。  

1. WSL(Ubuntu)をインストール  
コマンドプロンプトを管理者権限で開いて以下を実行する。
    ```
    wsl --install -d ubuntu
    ```
1. WSLバージョンを確認/切り替え  
    コマンドプロンプトで以下を実行する。
    ```
    wsl -l -v
    ```
    バージョンが1なら以下のコマンドで2に切り替える。  
    ```
    wsl --set-version Ubuntu 2
    ```

### PX4 Toolchainをインストールする(WSL Ubuntuに)  
参考:[Windows Development Environment (WSL2-Based)](https://docs.px4.io/main/en/dev_setup/dev_env_windows_wsl.html)

1. Ubuntuの起動  
    スタートメニューでUbuntuアプリを検索して実行。  
1. PX4ソースコードダウンロード  
    Ubuntuターミナル上で以下を実行(homeディレクトリ)  
    ```
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive
    ```
1. セットアップスクリプトの実行  
    以下を実行する。
    ```
    bash ./PX4-Autopilot/Tools/setup/ubuntu.sh
    ```
1. WSLの再起動  
    Ubuntuを閉じて、再度開く。  

1. ビルドできるか確認  
    ```
    cd ~/PX4-Autopilot
    make px4_sitl
    ```

### VSCode環境を構築する  
1. [ここ](https://code.visualstudio.com/)からVSCodeをダウンロードしてインストールする。(Windows上に)  
1. Remote-WSL拡張を追加する。
    1. VSCodeを起動する。  
    1. 左のバーから拡張機能(Extension)を選択する。  
    1. wslで検索してインストールする。 

1. VSCodeでWSL上のソースファイルを開く  
    1. Ubuntuを開く。  
    1. PX4ソースディレクトリに移動する。  
        ```
        cd PX4-Autopilot
        ```
    1. VSCodeでそのディレクトリを開く。  
        ```
        code .
        ```
    1. 拡張機能をインストールするか聞かれるのですべてインストールする。

### QGroundControlStationの環境を構築する(Windows)  
1. [ここ](https://docs.qgroundcontrol.com/master/en/getting_started/download_and_install.html)からインストーラをダウンロードしてインストールする。   
1. Ubuntuを起動する。  
1. Ubuntuターミナル上で以下のコマンドを実行してIPを調べる。(inet)  
    ```
    ip addr | grep eth0
    ```
1. スタートバーにQgroundControlと入力してQGCを立ち上げる。 
1. QGC上で新しい通信リンクを作成する。  
    アプリケーション設定→通信リンク→追加  
    名前は適当に入力してUDP選択。  
    port：`18570`、IP：（上で調べたやつ）でサーバ追加。（WSLは動的にIPが割り振られるので毎回設定必要。）

# 実行  
1. WindowsPCのIPアドレスを調べる。  
    コマンドプロンプトを開いて以下を実行。  
    ```
    ipconfig
    ```
1. start.shを書き換える。  
    ```
    export PX4_SIM_HOST_ADDR = 上で調べたIPアドレス(例えば192.168.1.6)
    ```
1. start.shをUbuntuにコピーする。  
1. simulinkモデルを開いて実行する。(pixhawk_sil_connector_example.slx)  
1. Ubuntuのターミナルで以下を実行する。
    ```
    cd ~/PX4-Autopilot
    ./start.sh
    ```

## VSCodeによるデバッグ  
1. simulinkモデルを開いて実行する。(pixhawk_sil_connector_example.slx)  
1. Ubuntuを立ち上げる。  
1. PX4ソースディレクトリに移動する  
    ```
    cd PX4-Autopilot
    ```
1. 以下のコマンドでIPアドレスを設定する。  
    ```
    export PX4_SIM_HOST_ADDR=x.x.x.x (4.IP設定と同じ)
    ```
1. VSCodeでそのディレクトリを開く。  
    ```
    code .
    ```
1. 左のタブから実行とデバッグを選択。  
1. lunch.jsonを開いて、以下を追加。  
    ```
    {
        "name": "SITL (simulink)",
        "type": "cppdbg",
        "request": "launch",
        "program": "${command:cmake.launchTargetPath}",
        "args": [
            "${workspaceFolder}/ROMFS/px4fmu_common"
        ],
        "stopAtEntry": false,
        "cwd": "${command:cmake.buildDirectory}/rootfs",
        "environment": [
            {
                "name": "PX4_SIM_MODEL",
                "value": "none_iris"
            }
        ],
        "postDebugTask": "px4_sitl_cleanup",
        "linux": {
            "MIMode": "gdb",
            "externalConsole": false,
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "PX4 ignore wq signals",
                    "text": "handle SIGCONT nostop noprint nopass",
                    "ignoreFailures": true
                }
            ]
        },
        "osx": {
            "MIMode": "lldb",
            "externalConsole": true,
            "setupCommands": [
                {
                    "text": "pro hand -p true -s false -n false SIGCONT",
                }
            ]
        }
    }
    ```
1. 実行とデバッグのドロップダウンから、上記で追加したSITL (simulink)を選択してデバッグ開始。
1. 好きなところにブレークポイントを設定する。

参考:[SITL Debugging](https://docs.px4.io/main/en/dev_setup/vscode.html#visual-studio-code-ide-vscode)


## fork元の変更をこのリポジトリにmergeする

fork元に更新があったときに、このリポジトリにも反映したいことがあるので、そのやり方メモ。
1. fork元をリモートリポジトリに追加する。(例えばfork_originという名前で。)
    ```
    $ git remote add fork_origin https://github.com/aviumtechnologies/pixhawk-sil-connector.git
    ```

1. fetchしてmergeする。
    ```
    $ git fetch fork_origin
    $ git merge fork_origin/master
    ```
    
    
[参考:fork 元のリポジトリの更新を fork 先に merge する](https://nobilearn.medium.com/fork-%E5%85%83%E3%81%AE%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E3%81%AE%E6%9B%B4%E6%96%B0%E3%82%92-fork-%E5%85%88%E3%81%AB-merge-%E3%81%99%E3%82%8B-6fa138921c93)


# ↓fork元のREADME↓
# Pixhawk SIL Connector for Simulink

Simulink C++ S-function for software-in-the-loop simulation with Pixhawk.

[![View Pixhawk software-in-the-loop (SIL) connector for Simulink on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/114320-pixhawk-software-in-the-loop-sil-connector-for-simulink)

Requirements
- MATLAB & Simulink (MATLAB R2022a or earlier)
- MinGW-w64 or MSVC C/C++ Compiler
- QGroundControl
- PX4-Autopilot source code (the latest stable release) \
https://github.com/PX4/PX4-Autopilot
- Windows Subsystem for Linux (WSL 2) \
https://learn.microsoft.com/en-us/windows/wsl/about

Files

[pixhawk_sil_connector.cpp](https://github.com/aviumtechnologies/pixhawk-sil-connector/blob/master/pixhawk_sil_connector.cpp)
<div style="height:1px; background-color:rgba(0,0,0,0.12);"></div>

[make.m](https://github.com/aviumtechnologies/pixhawk-sil-connector/blob/master/make.m)
<div style="height:1px; background-color:rgba(0,0,0,0.12);"></div>

[includes.zip](https://github.com/aviumtechnologies/pixhawk-sil-connector/blob/master/includes.zip) (contains the Asio C++ and MAVLink C libraries)
<div style="height:1px; background-color:rgba(0,0,0,0.12);"></div>

Build instructions

-  Install MATLAB-supported compiler  
https://mathworks.com/support/requirements/supported-compilers.html.
-  Download the "pixhawk_sil_connector.cpp" and "make.m" files and the "includes.zip" archive.
-  Unzip the "includes.zip archive".
-  Run "make.m" to create a "pixhawk_sil_connector.mexw64" (Windows), "pixhawk_sil_connector.mexa64" (Linux), "pixhawk_sil_connector.mexmaci64" (macOS) file.

Note: If you are using a compiler other than MSVC (e.g. MinGW64) you need to add the -lws2_32 flag to the "mex" command in the "make.m" file.

Use instructions (Simulink model running in Windows, PX4 Autopilot running in WSL 2)

- Download and install QGroundControl for Windows [https://docs.qgroundcontrol.com/master/en/getting_started/download_and_install.html](https://docs.qgroundcontrol.com/master/en/getting_started/download_and_install.html).
- Create a new "Comm Link" in QGroundControl via the "Application Settings" page. The type of the link must be UDP, thed port 18570, and the server address must be the ip address of the WLS 2 instance. You can use the "ip addr" command to find the ip of the WSL 2 instance. Note that the ip of the WSL  isntance will change every time you relaunch the instance.
- Open and run "pixhawk_sil_connector_example.slx".
- Build the PX4-Autopilot source code in WSL 2 using the following commands:  <pre>
git clone --recursive https://github.com/PX4/PX4-Autopilot
cd PX4-Autopilot
git checkout v1.13.x #(PX4 version)
git submodule sync --recursive
git submodule update --init --recursive
export PX4_SIM_HOST_ADDR=x.x.x.x #(the ip of the computer running the Simulink model)
make px4_sitl none_iris</pre>  [https://docs.px4.io/master/en/dev_setup/building_px4.html](https://docs.px4.io/master/en/dev_setup/building_px4.html) \
[https://docs.px4.io/main/en/simulation/](https://docs.px4.io/main/en/simulation/).


- If you already have a build of the PX4-Autopilit source code start PX4 using the following commands: <pre>
export PX4_SIM_HOST_ADDR=x.x.x.x #(the ip of the computer running the Simulink model)
export PX4_SIM_MODEL=iris
./bin/px4 -s etc/init.d-posix/rcS
</pre>

[![Demonstration of the Pixhawk SIL connector example](https://i.ytimg.com/vi/9y0QYBQ-L3I/maxresdefault.jpg)](https://youtu.be/9y0QYBQ-L3I)

<p align="center">Demonstration of the Pixhawk SIL connector example</p>

![Pixhawk SIL connector example](pixhawk_sil_connector_example.png)

<p align="center">Pixhawk SIL connector example</p>

![Pixhawk SIL connector sensors](pixhawk_sil_connector_example_sensors.png)

<p align="center">Pixhawk SIL connector example sensors</p>

Additional information available at:

https://fst.aviumtechnologies.com/pixhawk-sil-connector

