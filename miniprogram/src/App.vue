<script setup lang="ts">
import { onLaunch } from '@dcloudio/uni-app'
import { devLogin } from './utils/auth'

onLaunch(async () => {
  const token = uni.getStorageSync('token')
  if (!token) {
    try {
      await devLogin('test_user_1')
      console.log('测试登录成功')
    } catch (e) {
      console.error('登录失败', e)
    }
  }
})
</script>

<style>
page {
  background-color: #0a0e27;
  color: #e8ecf4;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'PingFang SC',
    'Microsoft YaHei', sans-serif;
  min-height: 100vh;
}

/* 全局工具类 */
.safe-area-top {
  padding-top: env(safe-area-inset-top);
}
.safe-area-bottom {
  padding-bottom: env(safe-area-inset-bottom);
}

/* ===== 毛玻璃 — 深色主题 ===== */
.glass {
  background: linear-gradient(165deg, rgba(255,255,255,0.12) 0%, rgba(255,255,255,0.04) 100%);
  border: 1rpx solid rgba(255,255,255,0.18);
  border-radius: 24rpx;
  box-shadow: 0 8rpx 32rpx rgba(0,0,0,0.4),
              inset 0 1rpx 0 rgba(255,255,255,0.2);
}
.glass-light {
  background: linear-gradient(165deg, rgba(255,255,255,0.08) 0%, rgba(255,255,255,0.02) 100%);
  border: 1rpx solid rgba(255,255,255,0.12);
  border-radius: 20rpx;
  box-shadow: 0 4rpx 24rpx rgba(0,0,0,0.3),
              inset 0 1rpx 0 rgba(255,255,255,0.15);
}
.glass-strong {
  background: linear-gradient(165deg, rgba(255,255,255,0.16) 0%, rgba(255,255,255,0.07) 100%);
  border: 1rpx solid rgba(255,255,255,0.22);
  border-radius: 24rpx;
  box-shadow: 0 8rpx 40rpx rgba(0,0,0,0.5),
              inset 0 1rpx 0 rgba(255,255,255,0.25);
}
</style>
