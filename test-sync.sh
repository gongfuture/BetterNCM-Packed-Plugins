#!/bin/bash

# BetterNCM 插件同步测试脚本
# 用于测试工作流的核心逻辑

set -e

echo "🔍 开始测试插件同步逻辑..."

# 检查必要的目录
echo "📁 检查目录结构..."
if [ ! -d "up-repositry" ]; then
    echo "❌ 错误: 未找到 up-repositry 目录"
    exit 1
fi

if [ ! -d "up-repositry/plugins-data" ]; then
    echo "❌ 错误: 未找到 plugins-data 目录"
    exit 1
fi

echo "✅ 目录结构检查通过"

# 模拟检查更新逻辑
echo "🔄 模拟检查更新..."
cd up-repositry

# 获取最新的 plugins-data 提交
LATEST_COMMIT=$(git log -1 --format="%H" -- plugins-data 2>/dev/null || echo "unknown")
echo "最新 plugins-data 提交: $LATEST_COMMIT"

cd ..

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

# 检查打包脚本
echo "📦 检查打包脚本..."
if [ ! -f "up-repositry/scripts/pack-plugins/pack-plugins.js" ]; then
    echo "❌ 错误: 未找到打包脚本"
    exit 1
fi

echo "✅ 打包脚本存在"

# 检查依赖文件
echo "📋 检查依赖配置..."
if [ ! -f "up-repositry/package.json" ]; then
    echo "⚠️ 警告: 未找到根目录 package.json"
fi

# 检查插件数据
echo "🔢 统计插件数据..."
PLUGIN_COUNT=$(find up-repositry/plugins-data -maxdepth 1 -type d | wc -l)
PLUGIN_COUNT=$((PLUGIN_COUNT - 1)) # 减去plugins-data目录本身
echo "插件数量: $PLUGIN_COUNT"

# 检查现有打包文件
echo "📁 检查现有打包文件..."
if [ -d "plugins" ]; then
    PACKED_COUNT=$(find plugins -name "*.plugin" | wc -l)
    echo "已打包插件数量: $PACKED_COUNT"
else
    echo "⚠️ 警告: 未找到 plugins 目录"
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
echo "=================================================="
