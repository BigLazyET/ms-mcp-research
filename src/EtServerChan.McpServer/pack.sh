#!/bin/bash

# ============================================================
# Server酱 MCP Server - NuGet 打包脚本
# ============================================================
# 用法:
#   ./pack.sh              # 默认打包 (Debug 配置)
#   ./pack.sh Release      # Release 配置打包
#   ./pack.sh Release 1.0.0  # 指定版本号打包
# ============================================================

set -e  # 遇到错误立即退出

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 配置参数
CONFIGURATION="${1:-Debug}"
VERSION="${2:-}"
OUTPUT_DIR="./nupkg"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}Server酱 MCP Server - NuGet 打包${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""

# 检查 dotnet 是否安装
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}错误: 未找到 dotnet CLI，请先安装 .NET SDK${NC}"
    exit 1
fi

echo -e "${YELLOW}配置: ${CONFIGURATION}${NC}"
if [ -n "$VERSION" ]; then
    echo -e "${YELLOW}版本: ${VERSION}${NC}"
fi
echo -e "${YELLOW}输出目录: ${OUTPUT_DIR}${NC}"
echo ""

# 清理之前的构建
echo -e "${GREEN}[1/4] 清理之前的构建...${NC}"
dotnet clean -c "$CONFIGURATION" --nologo -v q

# 还原依赖
echo -e "${GREEN}[2/4] 还原 NuGet 依赖...${NC}"
dotnet restore --nologo -v q

# 构建项目
echo -e "${GREEN}[3/4] 构建项目...${NC}"
dotnet build -c "$CONFIGURATION" --no-restore --nologo

# 创建 NuGet 包
echo -e "${GREEN}[4/4] 创建 NuGet 包...${NC}"
mkdir -p "$OUTPUT_DIR"

if [ -n "$VERSION" ]; then
    dotnet pack -c "$CONFIGURATION" --no-build --nologo \
        -o "$OUTPUT_DIR" \
        -p:PackageVersion="$VERSION"
else
    dotnet pack -c "$CONFIGURATION" --no-build --nologo \
        -o "$OUTPUT_DIR"
fi

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}打包完成！${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""

# 显示生成的包
echo -e "${YELLOW}生成的 NuGet 包:${NC}"
ls -la "$OUTPUT_DIR"/*.nupkg 2>/dev/null || echo "未找到 .nupkg 文件"

echo ""
echo -e "${YELLOW}发布到 NuGet.org:${NC}"
echo "  dotnet nuget push $OUTPUT_DIR/*.nupkg --api-key YOUR_API_KEY --source https://api.nuget.org/v3/index.json"
echo ""
echo -e "${YELLOW}本地测试安装:${NC}"
echo "  dotnet tool install --global --add-source $OUTPUT_DIR EtServerChan.McpServer"
