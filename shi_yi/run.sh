#!/bin/bash

# Flutter 运行脚本
# 使用方法: ./run.sh [平台]
# 平台选项: macos, ios, chrome, android, ohos (默认: macos)

cd "$(dirname "$0")"

PLATFORM=${1:-macos}

case $PLATFORM in
  macos)
    echo "🚀 运行到 macOS..."
    flutter run -d macos
    ;;
  ios)
    echo "🚀 运行到 iOS..."
    # 获取第一个 iOS 设备
    IOS_DEVICE=$(flutter devices | grep -E "ios.*•" | head -1 | awk '{print $NF}')
    if [ -z "$IOS_DEVICE" ]; then
      echo "❌ 未找到 iOS 设备"
      exit 1
    fi
    flutter run -d "$IOS_DEVICE"
    ;;
  chrome)
    echo "🚀 运行到 Chrome..."
    flutter run -d chrome
    ;;
  android)
    echo "🚀 运行到 Android..."
    ANDROID_DEVICE=$(flutter devices | grep -E "android.*•" | head -1 | awk '{print $NF}')
    if [ -z "$ANDROID_DEVICE" ]; then
      echo "❌ 未找到 Android 设备"
      exit 1
    fi
    flutter run -d "$ANDROID_DEVICE"
    ;;
  ohos)
    echo "🚀 运行到鸿蒙设备..."
    # 获取第一个 ohos 设备
    OHOS_DEVICE=$(flutter devices | grep -E "ohos.*•" | head -1 | awk '{print $NF}')
    if [ -z "$OHOS_DEVICE" ]; then
      echo "❌ 未找到鸿蒙设备"
      echo "💡 提示: 请确保鸿蒙设备已连接并开启开发者模式"
      exit 1
    fi
    flutter run -d "$OHOS_DEVICE"
    ;;
  *)
    echo "❌ 未知平台: $PLATFORM"
    echo "可用平台: macos, ios, chrome, android, ohos"
    exit 1
    ;;
esac

