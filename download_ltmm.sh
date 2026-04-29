#!/bin/bash
# LTMM 数据集下载脚本（简化版）
# 只下载人口学特征和 3D 加速度计原始信号
# 跳过 LabWalks 和其他不需要的文件

set -e

# 配置
DATA_DIR="../data/ltmm"
S3_BUCKET="s3://physionet-open/ltmm/1.0.0"

echo "=========================================="
echo "LTMM 数据集下载脚本（简化版）"
echo "=========================================="
echo ""

# 创建目录
echo "[1/4] 创建数据目录：$DATA_DIR"
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

# 检查 AWS CLI
if ! command -v aws &> /dev/null; then
    echo "错误：未找到 AWS CLI"
    echo "请先安装：pip install awscli"
    echo "或者：conda install -c conda-forge awscli"
    exit 1
fi

echo "[2/4] AWS CLI 已安装，版本："
aws --version

# 下载人口学数据和文档
echo ""
echo "[3/4] 下载人口学数据和文档..."
aws s3 cp --no-sign-request \
    "$S3_BUCKET/ClinicalDemogData_COFL.xlsx" \
    "./ClinicalDemogData_COFL.xlsx"

aws s3 cp --no-sign-request \
    "$S3_BUCKET/README.txt" \
    "./README.txt"

# 下载加速度计数据（排除 LabWalks）
echo ""
echo "[4/4] 下载 3D 加速度计数据（约 17.7GB）..."
echo "这将需要一些时间，请耐心等待..."
echo ""

aws s3 sync --no-sign-request \
    "$S3_BUCKET/" \
    "./" \
    --exclude "*" \
    --include "CO*.dat" \
    --include "CO*.hea" \
    --include "FL*.dat" \
    --include "FL*.hea" \
    --include "ClinicalDemogData_COFL.xlsx" \
    --include "README.txt" \
    --exclude "LabWalks/*" \
    --exclude "ReportHome75h.xlsx"

# 验证下载
echo ""
echo "=========================================="
echo "下载完成！验证文件..."
echo "=========================================="
echo ""

# 统计文件数量
DAT_COUNT=$(ls -1 *.dat 2>/dev/null | wc -l)
HEA_COUNT=$(ls -1 *.hea 2>/dev/null | wc -l)

echo "下载的 .dat 文件数量：$DAT_COUNT"
echo "下载的 .hea 文件数量：$HEA_COUNT"
echo ""

# 统计总大小
TOTAL_SIZE=$(du -sh . 2>/dev/null | cut -f1)
echo "总数据量：$TOTAL_SIZE"
echo ""

# 列出前 10 个文件
echo "前 10 个文件："
ls -lh *.dat | head -10

echo ""
echo "=========================================="
echo "✅ 下载完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "1. 查看 README.txt 了解数据格式"
echo "2. 打开 ClinicalDemogData_COFL.xlsx 查看样本信息"
echo "3. 使用 Python 读取 .dat 文件（需要 wfdb 库）"
echo ""
echo "Python 示例："
echo "  import wfdb"
echo "  record = wfdb.rdrecord('CO001')"
echo "  print(record.p_signal.shape)"
echo ""
