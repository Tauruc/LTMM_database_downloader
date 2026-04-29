# LTMM 数据下载指南

本指南帮助您下载 LTMM 数据集的必需文件（约 17.7GB，而非全部 20.8GB）。

## 📦 下载内容

### 必需文件
- ✅ **人口学数据**: `ClinicalDemogData_COFL.xlsx` (~30KB)
- ✅ **加速度计信号**: 71 位受试者的 `.dat` + `.hea` 文件 (~17.7GB)
  - 非跌倒者：CO001-CO044 (44 人)
  - 跌倒者：FL001-FL027 (27 人)
- ✅ **说明文档**: `README.txt`

### 跳过文件（不下载）
- ❌ `LabWalks/` 子目录 (~2-3GB) - 实验室 1 分钟步行数据
- ❌ `ReportHome75h.xlsx` (~22KB) - 设备日志

---

## 🚀 方法一：使用下载脚本（推荐）

### Windows 用户

1. **打开命令提示符**（Win + R，输入 `cmd`，回车）

2. **进入脚本目录**：
   ```cmd
   cd e:\Research\Statistical-Modeling\topic-fusion\scripts
   ```

3. **运行下载脚本**：
   ```cmd
   download_ltmm.bat
   ```

4. **等待下载完成**（约 30 分钟，取决于网速）

### Linux/Mac 用户

1. **打开终端**

2. **进入脚本目录**：
   ```bash
   cd /path/to/topic-fusion/scripts
   ```

3. **赋予执行权限**：
   ```bash
   chmod +x download_ltmm.sh
   ```

4. **运行下载脚本**：
   ```bash
   ./download_ltmm.sh
   ```

---

## 🔧 方法二：手动下载（如果脚本失败）

### 步骤 1：安装 AWS CLI

**使用 pip**：
```bash
pip install awscli
```

**使用 conda**：
```bash
conda install -c conda-forge awscli
```

### 步骤 2：创建数据目录

```bash
cd e:\Research\Statistical-Modeling\topic-fusion
mkdir -p data\ltmm
cd data\ltmm
```

### 步骤 3：下载人口学数据

```bash
aws s3 cp --no-sign-request ^
  s3://physionet-open/ltmm/1.0.0/ClinicalDemogData_COFL.xlsx ^
  .\ClinicalDemogData_COFL.xlsx

aws s3 cp --no-sign-request ^
  s3://physionet-open/ltmm/1.0.0/README.txt ^
  .\README.txt
```

### 步骤 4：下载加速度计数据

**方法 A：使用 sync（推荐，但 Windows 支持有限）**

Linux/Mac:
```bash
aws s3 sync --no-sign-request \
  s3://physionet-open/ltmm/1.0.0/ \
  ./ \
  --exclude "*" \
  --include "CO*.dat" \
  --include "CO*.hea" \
  --include "FL*.dat" \
  --include "FL*.hea" \
  --exclude "LabWalks/*"
```

**方法 B：手动下载每个文件**

Windows 批处理（保存为 `download_manual.bat`）：
```batch
@echo off
for /l %%i in (1,1,44) do (
    set "NUM=00%%i"
    set "NUM=!NUM:~-3!"
    echo 下载 CO!NUM!.dat...
    aws s3 cp --no-sign-request s3://physionet-open/ltmm/1.0.0/CO!NUM!.dat .\CO!NUM!.dat
    aws s3 cp --no-sign-request s3://physionet-open/ltmm/1.0.0/CO!NUM!.hea .\CO!NUM!.hea
)

for /l %%i in (1,1,27) do (
    set "NUM=00%%i"
    set "NUM=!NUM:~-3!"
    echo 下载 FL!NUM!.dat...
    aws s3 cp --no-sign-request s3://physionet-open/ltmm/1.0.0/FL!NUM!.dat .\FL!NUM!.dat
    aws s3 cp --no-sign-request s3://physionet-open/ltmm/1.0.0/FL!NUM!.hea .\FL!NUM!.hea
)
```

---

## ⏱️ 预计下载时间

| 网速 | 下载 17.7GB 所需时间 |
|------|---------------------|
| 50 Mbps | ~1 小时 |
| 100 Mbps | ~30 分钟 |
| 200 Mbps | ~15 分钟 |
| 500 Mbps | ~6 分钟 |

---

## ✅ 验证下载

### 检查文件数量

**Windows**：
```cmd
cd e:\Research\Statistical-Modeling\topic-fusion\data\ltmm
dir /b *.dat | find /c ".dat"
dir /b *.hea | find /c ".hea"
```

**Linux/Mac**：
```bash
cd /path/to/topic-fusion/data/ltmm
ls -1 *.dat | wc -l
ls -1 *.hea | wc -l
```

**预期结果**：
- `.dat` 文件：71 个
- `.hea` 文件：71 个

### 检查文件大小

```bash
# Windows
dir *.dat | find "字节"

# Linux/Mac
du -sh *.dat | head -10
```

**单个文件大小**：约 200-300MB

---

## 🐍 使用 Python 读取数据

### 安装依赖

```bash
pip install wfdb pandas openpyxl
```

### 读取示例

```python
import wfdb
import pandas as pd

# 1. 读取人口学数据
demog = pd.read_excel('ClinicalDemogData_COFL.xlsx')
print(demog.head())
print(demog.columns)

# 2. 读取加速度计数据（以 CO001 为例）
record = wfdb.rdrecord('CO001')
print(f"信号形状：{record.p_signal.shape}")
print(f"采样频率：{record.fs} Hz")
print(f"信号通道：{record.sig_name}")

# 3. 可视化
import matplotlib.pyplot as plt

plt.figure(figsize=(12, 6))
plt.plot(record.p_signal[:10000])  # 前 10000 个点
plt.xlabel('样本点')
plt.ylabel('加速度')
plt.title('CO001 - 3D 加速度计信号')
plt.legend(record.sig_name)
plt.savefig('CO001_sample.png', dpi=300)
plt.show()
```

---

## ❓ 常见问题

### Q1: AWS CLI 安装失败？
**A**: 尝试使用 conda 安装：
```bash
conda install -c conda-forge awscli
```

### Q2: 下载速度很慢？
**A**: 
- 检查网络连接
- 尝试在非高峰时段下载
- 考虑使用学校的网络（可能更快）

### Q3: 下载中断了怎么办？
**A**: 重新运行脚本，AWS CLI 会自动跳过已下载的文件

### Q4: 磁盘空间不足？
**A**: 确保至少有 20GB 可用空间（17.7GB 数据 + 临时文件）

---

## 📞 需要帮助？

如果遇到问题，请检查：
1. AWS CLI 是否正确安装：`aws --version`
2. 网络连接是否正常
3. 磁盘空间是否充足
4. 脚本是否有执行权限（Linux/Mac）

---

**下一步**：
1. ✅ 下载完成
2. 📖 阅读 `README.txt` 了解数据格式
3. 🐍 使用 Python 读取并探索数据
