#!/bin/bash

# BetterNCM 插件同步测试脚本
# 用于测试工作流的核心逻辑

set -e

echo "🔍 开始测试插件同步逻辑..."

# 模拟检查更新逻辑
echo "� 模拟检查源仓库更新..."

# 使用GitHub API获取源仓库的最新提交（模拟真实workflow的行为）
echo "📡 获取源仓库最新提交信息..."
LATEST_COMMIT_INFO=$(curl -s "https://api.github.com/repos/BetterNCM/BetterNCM-Plugins/commits?path=plugins-data&per_page=1" | head -20)

if [ -n "$LATEST_COMMIT_INFO" ]; then
    echo "✅ 成功获取源仓库信息"
    # 这里只是模拟，实际workflow会用git log获取
    LATEST_COMMIT="mock-commit-$(date +%s)"
else
    echo "⚠️ 无法获取源仓库信息，使用模拟数据"
    LATEST_COMMIT="mock-commit-$(date +%s)"
fi

echo "模拟最新 plugins-data 提交: $LATEST_COMMIT"

# 检查上次同步记录
if [ -f ".last-sync-commit" ]; then
    LAST_SYNC_COMMIT=$(cat .last-sync-commit)
    echo "上次同步提交: $LAST_SYNC_COMMIT"
    
    if [ "$LATEST_COMMIT" != "$LAST_SYNC_COMMIT" ]; then
        echo "✅ 检测到更新，需要同步"
        HAS_CHANGES=true
    else
        echo "ℹ️ 无更新，跳过同步"
        HAS_CHANGES=false
    fi
else
    echo "⚠️ 首次运行，将创建同步记录"
    HAS_CHANGES=true
fi

# 检查工作流文件
echo "� 检查工作流配置..."
if [ ! -f ".github/workflows/sync-and-pack.yml" ]; then
    echo "❌ 错误: 未找到同步工作流文件"
    exit 1
fi

echo "✅ 工作流文件存在"

# 检查必要文件的保护列表
echo "�️ 检查文件保护配置..."
PROTECTED_FILES=(
    ".git"
    ".github"
    ".last-sync-commit"
    "WORKFLOW_README.md"
    "README.md"
    "test-sync.sh"
    "check-status.sh"
)

echo "受保护的文件/目录:"
for file in "${PROTECTED_FILES[@]}"; do
    if [ -e "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ⚠️ $file (不存在)"
    fi
done

# 检查现有打包文件
echo "� 检查现有打包文件..."
if [ -d "plugins" ]; then
    PACKED_COUNT=$(find plugins -name "*.plugin" 2>/dev/null | wc -l || echo "0")
    echo "已打包插件数量: $PACKED_COUNT"
else
    echo "⚠️ 警告: 未找到 plugins 目录"
fi

if [ -f "plugins.json" ]; then
    PLUGIN_COUNT=$(grep -o '"name":' plugins.json 2>/dev/null | wc -l || echo "0")
    echo "plugins.json 中的插件数量: $PLUGIN_COUNT"
else
    echo "⚠️ 警告: 未找到 plugins.json 文件"
fi

# 模拟创建同步记录
if [ "$HAS_CHANGES" == "true" ]; then
    echo "📝 更新同步记录..."
    echo "$LATEST_COMMIT" > .last-sync-commit
    echo "✅ 同步记录已更新"
fi

# 检查GitHub Actions权限
echo "🔐 检查GitHub配置..."
if [ -n "$GITHUB_ACTIONS" ]; then
    echo "✅ 运行在GitHub Actions环境中"
else
    echo "ℹ️ 本地测试环境"
fi

echo ""
echo "🎉 测试完成！"
echo "=================================================="
if [ "$HAS_CHANGES" == "true" ]; then
    echo "状态: 需要同步"
    echo "建议: 可以手动触发 GitHub Actions 工作流"
    echo "触发方式: 在GitHub仓库的Actions页面点击'Sync and Pack Plugins' -> 'Run workflow'"
else
    echo "状态: 无需同步"
    echo "建议: 等待下次定时检查"
fi
echo "=================================================="
