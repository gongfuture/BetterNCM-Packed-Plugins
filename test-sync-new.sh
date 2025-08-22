#!/bin/bash

# BetterNCM 插件同步测试脚本
# 用于测试工作流的核心逻辑

set -e

echo "🔍 开始测试插件同步逻辑..."

# 检查工作流文件
echo "📁 检查工作流配置..."
if [ ! -f ".github/workflows/sync-and-pack.yml" ]; then
    echo "❌ 错误: 未找到同步工作流文件"
    exit 1
fi

echo "✅ 工作流配置检查通过"

# 模拟检查更新逻辑（使用GitHub API）
echo "🔄 模拟检查更新..."

if command -v curl >/dev/null 2>&1; then
    echo "📡 获取源仓库最新提交..."
    API_RESPONSE=$(curl -s "https://api.github.com/repos/BetterNCM/BetterNCM-Plugins/commits?path=plugins-data&per_page=1" 2>/dev/null)
    
    if echo "$API_RESPONSE" | grep -q '"sha"'; then
        LATEST_COMMIT=$(echo "$API_RESPONSE" | grep -o '"sha":"[^"]*' | head -1 | cut -d'"' -f4)
        echo "最新 plugins-data 提交: $LATEST_COMMIT"
    else
        echo "⚠️ 无法获取源仓库信息，使用模拟数据"
        LATEST_COMMIT="mock-commit-hash"
    fi
else
    echo "⚠️ 未安装curl，使用模拟数据"
    LATEST_COMMIT="mock-commit-hash"
fi

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

# 检查现有打包文件
echo "📁 检查现有打包文件..."
if [ -d "plugins" ]; then
    PACKED_COUNT=$(find plugins -name "*.plugin" | wc -l)
    echo "已打包插件数量: $PACKED_COUNT"
else
    echo "⚠️ 警告: 未找到 plugins 目录"
fi

if [ -f "plugins.json" ]; then
    PLUGIN_COUNT=$(grep -o '"name":' plugins.json | wc -l 2>/dev/null || echo "0")
    echo "plugins.json中的插件数量: $PLUGIN_COUNT"
else
    echo "⚠️ 警告: 未找到 plugins.json 文件"
fi

# 模拟创建同步记录
if [ "$HAS_CHANGES" == "true" ]; then
    echo "📝 更新同步记录..."
    echo "$LATEST_COMMIT" > .last-sync-commit
    echo "✅ 同步记录已更新"
fi

echo ""
echo "🎉 测试完成！"
echo "=================================================="
if [ "$HAS_CHANGES" == "true" ]; then
    echo "状态: 需要同步"
    echo "建议: 可以手动触发 GitHub Actions 工作流"
else
    echo "状态: 无需同步"
    echo "建议: 等待下次定时检查"
fi
echo "工作流特性:"
echo "  ✅ 保留历史版本插件"
echo "  ✅ 自动备份和恢复workflows"
echo "  ✅ 清理临时文件"
echo "  ✅ 智能增量更新"
echo "=================================================="
