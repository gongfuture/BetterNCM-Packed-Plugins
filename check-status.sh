#!/bin/bash

# BetterNCM 插件同步状态检查脚本

echo "📊 BetterNCM 插件同步状态检查"
echo "=================================="

# 检查同步记录
if [ -f ".last-sync-commit" ]; then
    LAST_SYNC=$(cat .last-sync-commit)
    echo "📋 上次同步提交: $LAST_SYNC"
    echo "📅 同步记录时间: $(date -r .last-sync-commit 2>/dev/null || echo "unknown")"
    
    # 使用GitHub API检查源仓库最新状态
    echo "📡 检查源仓库最新状态..."
    if command -v curl >/dev/null 2>&1; then
        API_RESPONSE=$(curl -s "https://api.github.com/repos/BetterNCM/BetterNCM-Plugins/commits?path=plugins-data&per_page=1" 2>/dev/null)
        if echo "$API_RESPONSE" | grep -q '"sha"'; then
            echo "✅ 源仓库状态: 可访问"
            echo "💡 建议: 手动触发 GitHub Actions 工作流进行同步检查"
        else
            echo "⚠️ 源仓库状态: 无法访问或API限制"
        fi
    else
        echo "⚠️ 无法检查源仓库状态 (缺少curl命令)"
    fi
else
    echo "❌ 未找到同步记录，可能是首次运行"
fi

echo ""

# 检查本地插件统计
if [ -f "plugins.json" ]; then
    PLUGIN_COUNT=$(grep -o '"name":' plugins.json | wc -l 2>/dev/null || echo "0")
    echo "📦 当前插件数量: $PLUGIN_COUNT"
    
    # 检查最新几个插件
    echo "🆕 最近更新的插件:"
    if command -v jq >/dev/null 2>&1; then
        jq -r '.[] | select(.update_time != null) | "\(.name) - \(.version)"' plugins.json 2>/dev/null | head -5 | sed 's/^/   /'
    else
        echo "   (需要安装 jq 来显示详细信息)"
    fi
else
    echo "❌ 未找到 plugins.json 文件"
fi

echo ""

# 检查工作流状态
if [ -f ".github/workflows/sync-and-pack.yml" ]; then
    echo "✅ 自动同步工作流: 已配置"
    echo "📝 工作流文件: .github/workflows/sync-and-pack.yml"
    echo "⏰ 运行频率: 每6小时"
else
    echo "❌ 自动同步工作流: 未配置"
fi

echo ""
echo "🔗 有用的链接:"
echo "   GitHub Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
echo "   源仓库: https://github.com/BetterNCM/BetterNCM-Plugins"
echo ""
echo "=================================="
