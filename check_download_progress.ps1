# LTMM 数据下载监控脚本
# 用法：.\check_download_progress.ps1

$DATA_DIR = "e:\Research\Statistical-Modeling\topic-fusion\data\ltmm"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LTMM 数据下载进度监控" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $DATA_DIR)) {
    Write-Host "错误：数据目录不存在！" -ForegroundColor Red
    Write-Host "路径：$DATA_DIR" -ForegroundColor Yellow
    exit 1
}

Set-Location $DATA_DIR

# 统计文件
$dat_files = Get-ChildItem -Filter "*.dat" -ErrorAction SilentlyContinue
$hea_files = Get-ChildItem -Filter "*.hea" -ErrorAction SilentlyContinue

$dat_count = $dat_files.Count
$hea_count = $hea_files.Count

Write-Host "下载进度:" -ForegroundColor Green
Write-Host "  .dat 文件：$dat_count / 71" -ForegroundColor $(if($dat_count -eq 71){"Green"}else{"Yellow"})
Write-Host "  .hea 文件：$hea_count / 71" -ForegroundColor $(if($hea_count -eq 71){"Green"}else{"Yellow"})
Write-Host ""

# 计算已下载大小
$total_size = ($dat_files | Measure-Object -Property Length -Sum).Sum + 
              ($hea_files | Measure-Object -Property Length -Sum).Sum

$total_size_gb = [math]::Round($total_size / 1GB, 2)
$expected_size_gb = 17.7

Write-Host "数据大小:" -ForegroundColor Green
Write-Host "  已下载：$total_size_gb GB" -ForegroundColor Cyan
Write-Host "  预计总大小：$expected_size_gb GB" -ForegroundColor Gray
Write-Host "  完成度：$([math]::Round($total_size_gb / $expected_size_gb * 100, 1))%" -ForegroundColor $(if($total_size_gb -ge 17){"Green"}else{"Yellow"})
Write-Host ""

# 显示最新下载的文件
Write-Host "最新下载的 5 个文件:" -ForegroundColor Green
Get-ChildItem -Filter "*.dat" | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | Format-Table Name, @{Label="Size(MB)";Expression={[math]::Round($_.Length/1MB,1)}}, LastWriteTime -AutoSize

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "提示：下载仍在进行中，请等待..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
