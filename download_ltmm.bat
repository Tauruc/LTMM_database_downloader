@echo off
REM LTMM 数据集下载脚本（Windows 批处理版）
REM 只下载人口学特征和 3D 加速度计原始信号
REM 跳过 LabWalks 和其他不需要的文件

echo ==========================================
echo LTMM 数据集下载脚本（Windows 版）
echo ==========================================
echo.

REM 配置
set DATA_DIR=..\data\ltmm
set S3_BUCKET=s3://physionet-open/ltmm/1.0.0

echo [1/4] 创建数据目录：%DATA_DIR%
if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
cd /d "%DATA_DIR%"

REM 检查 AWS CLI
where aws >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误：未找到 AWS CLI
    echo 请先安装：pip install awscli
    echo 或者：conda install -c conda-forge awscli
    pause
    exit /b 1
)

echo [2/4] AWS CLI 已安装，版本：
aws --version
echo.

REM 下载人口学数据和文档
echo [3/4] 下载人口学数据和文档...
aws s3 cp --no-sign-request ^
    "%S3_BUCKET%/ClinicalDemogData_COFL.xlsx" ^
    ".\ClinicalDemogData_COFL.xlsx"

aws s3 cp --no-sign-request ^
    "%S3_BUCKET%/README.txt" ^
    ".\README.txt"

REM 下载加速度计数据（排除 LabWalks）
echo.
echo [4/4] 下载 3D 加速度计数据（约 17.7GB）...
echo 这将需要一些时间，请耐心等待...
echo.

REM Windows 下 aws sync 不支持复杂的 exclude/include
REM 使用分步下载

echo 下载非跌倒者数据 (CO001-CO044)...
for /l %%i in (1,1,44) do (
    set "NUM=00%%i"
    set "NUM=!NUM:~-3!"
    echo 下载 CO!NUM!.dat...
    aws s3 cp --no-sign-request "%S3_BUCKET%/CO!NUM!.dat" ".\CO!NUM!.dat"
    aws s3 cp --no-sign-request "%S3_BUCKET%/CO!NUM!.hea" ".\CO!NUM!.hea"
)

echo.
echo 下载跌倒者数据 (FL001-FL027)...
for /l %%i in (1,1,27) do (
    set "NUM=00%%i"
    set "NUM=!NUM:~-3!"
    echo 下载 FL!NUM!.dat...
    aws s3 cp --no-sign-request "%S3_BUCKET%/FL!NUM!.dat" ".\FL!NUM!.dat"
    aws s3 cp --no-sign-request "%S3_BUCKET%/FL!NUM!.hea" ".\FL!NUM!.hea"
)

REM 验证下载
echo.
echo ==========================================
echo 下载完成！验证文件...
echo ==========================================
echo.

dir /b *.dat | find /c ".dat" > temp_count.txt
set /p DAT_COUNT=<temp_count.txt
del temp_count.txt

dir /b *.hea | find /c ".hea" > temp_count.txt
set /p HEA_COUNT=<temp_count.txt
del temp_count.txt

echo 下载的 .dat 文件数量：%DAT_COUNT%
echo 下载的 .hea 文件数量：%HEA_COUNT%
echo.

echo 总数据量：
dir /s | find "个文件"

echo.
echo 前 10 个 .dat 文件：
dir /b *.dat | findstr /n "^" | findstr "[1-9]:"

echo.
echo ==========================================
echo 完成！
echo ==========================================
echo.
echo 下一步：
echo 1. 查看 README.txt 了解数据格式
echo 2. 打开 ClinicalDemogData_COFL.xlsx 查看样本信息
echo 3. 使用 Python 读取 .dat 文件（需要 wfdb 库）
echo.
echo Python 示例：
echo   import wfdb
echo   record = wfdb.rdrecord('CO001')
echo   print(record.p_signal.shape)
echo.

pause
