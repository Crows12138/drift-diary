<template>
  <view class="page safe-area-top">
    <view class="nav-bar">
      <text class="nav-back" @tap="goBack">← 返回</text>
      <text class="nav-title">漂流旅程</text>
      <view style="width: 80rpx;" />
    </view>

    <view v-if="loading" class="loading">
      <text class="loading-text">加载中...</text>
    </view>

    <view v-else-if="bottle" class="journey">
      <!-- 原始日记 -->
      <view class="glass origin-card">
        <view class="origin-header">
          <text class="origin-emoji">🍾</text>
          <text class="origin-label">我的漂流日记</text>
        </view>
        <text class="origin-content">{{ bottle.diary_content }}</text>
        <text class="origin-date">投出于 {{ formatDate(bottle.created_at) }}</text>
      </view>

      <!-- 漂流线 -->
      <view class="timeline">
        <view v-if="bottle.responses.length === 0" class="empty-journey">
          <text class="wave-emoji">🌊</text>
          <text class="empty-journey-text">你的漂流瓶还在海上漂流，等待被人捡起...</text>
        </view>
        <view
          v-for="(resp, i) in bottle.responses"
          :key="i"
          class="timeline-item"
        >
          <view class="timeline-dot" />
          <view class="timeline-line" v-if="i < bottle.responses.length - 1" />
          <view class="glass-light timeline-card">
            <view class="timeline-header">
              <text class="timeline-station">📍 第{{ resp.station_number }}站</text>
              <text class="timeline-date">{{ formatDate(resp.created_at) }}</text>
            </view>
            <text class="timeline-content">{{ resp.content }}</text>
          </view>
        </view>
      </view>

      <!-- 漂流状态 -->
      <view class="status-bar">
        <text class="status-text" v-if="bottle.status === 'drifting'">🌊 正在继续漂流中...</text>
        <text class="status-text" v-else-if="bottle.status === 'picked'">📖 正在被阅读中...</text>
      </view>

      <!-- 举报 -->
      <view class="report-section">
        <text class="report-link" @tap="showReport = true">举报不当内容</text>
      </view>
    </view>

    <!-- 举报弹窗 -->
    <view v-if="showReport" class="modal-mask" @tap="showReport = false">
      <view class="glass-strong modal-content" @tap.stop>
        <text class="modal-title">举报不当内容</text>
        <textarea
          v-model="reportReason"
          class="report-input"
          placeholder="请描述举报原因..."
          placeholder-style="color: rgba(255,255,255,0.25)"
        />
        <view class="modal-actions">
          <view class="glass modal-btn cancel" @tap="showReport = false">取消</view>
          <view class="modal-btn confirm" @tap="submitReport">提交</view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { api } from '@/utils/request'

const loading = ref(true)
const bottle = ref<any>(null)
const showReport = ref(false)
const reportReason = ref('')
let bottleId = 0

onLoad((query: any) => {
  bottleId = parseInt(query.bottleId || '0')
  loadJourney()
})

async function loadJourney() {
  try {
    bottle.value = await api.get<any>(`/api/drift/${bottleId}/journey`)
  } catch (e) {
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function formatDate(dateStr: string) {
  const d = new Date(dateStr)
  return `${d.getMonth() + 1}月${d.getDate()}日`
}

async function submitReport() {
  if (!reportReason.value.trim()) {
    uni.showToast({ title: '请填写举报原因', icon: 'none' })
    return
  }
  try {
    await api.post('/api/drift/report', {
      target_type: 'diary',
      target_id: bottleId,
      reason: reportReason.value.trim(),
    })
    uni.showToast({ title: '举报已提交', icon: 'none' })
    showReport.value = false
    reportReason.value = ''
  } catch (e) {
    // 错误已处理
  }
}

function goBack() {
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.page {
  padding: 0 32rpx;
  min-height: 100vh;
}
.nav-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 40rpx 0 20rpx;
}
.nav-back { font-size: 28rpx; color: #818cf8; width: 80rpx; }
.nav-title { font-size: 32rpx; color: #e8ecf4; font-weight: 600; }
.loading { display: flex; justify-content: center; padding: 200rpx 0; }
.loading-text { color: rgba(255,255,255,0.4); font-size: 30rpx; }
.origin-card {
  padding: 32rpx;
  margin: 24rpx 0;
}
.origin-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 16rpx;
}
.origin-emoji { font-size: 36rpx; }
.origin-label { font-size: 28rpx; color: #818cf8; font-weight: 500; }
.origin-content {
  font-size: 30rpx;
  color: rgba(255,255,255,0.85);
  line-height: 1.8;
  display: block;
  margin-bottom: 16rpx;
}
.origin-date { font-size: 22rpx; color: rgba(255,255,255,0.25); }
.timeline { padding: 8rpx 0 8rpx 20rpx; }
.empty-journey {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60rpx 0;
}
.wave-emoji { font-size: 48rpx; margin-bottom: 12rpx; }
.empty-journey-text { color: rgba(255,255,255,0.25); font-size: 26rpx; text-align: center; }
.timeline-item {
  position: relative;
  padding-left: 40rpx;
  padding-bottom: 32rpx;
}
.timeline-dot {
  position: absolute;
  left: 0;
  top: 12rpx;
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  background: #818cf8;
  box-shadow: 0 0 12rpx rgba(129,140,248,0.4);
}
.timeline-line {
  position: absolute;
  left: 6rpx;
  top: 32rpx;
  width: 4rpx;
  height: calc(100% - 20rpx);
  background: rgba(255,255,255,0.08);
}
.timeline-card {
  padding: 24rpx;
}
.timeline-header {
  display: flex;
  gap: 12rpx;
  margin-bottom: 12rpx;
}
.timeline-station { font-size: 24rpx; color: #818cf8; }
.timeline-date { font-size: 22rpx; color: rgba(255,255,255,0.25); }
.timeline-content { font-size: 28rpx; color: rgba(255,255,255,0.55); line-height: 1.6; }
.status-bar {
  text-align: center;
  padding: 32rpx;
}
.status-text { font-size: 26rpx; color: #818cf8; }
.report-section {
  text-align: center;
  padding: 20rpx;
}
.report-link { font-size: 24rpx; color: rgba(255,255,255,0.25); }
.modal-mask {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;
}
.modal-content {
  width: 600rpx;
  padding: 40rpx;
}
.modal-title {
  font-size: 32rpx;
  color: #e8ecf4;
  font-weight: 600;
  display: block;
  margin-bottom: 24rpx;
}
.report-input {
  width: 100%;
  min-height: 160rpx;
  background: rgba(255,255,255,0.05);
  border-radius: 16rpx;
  padding: 20rpx;
  font-size: 28rpx;
  color: rgba(255,255,255,0.85);
  margin-bottom: 24rpx;
  border: 1rpx solid rgba(255,255,255,0.1);
}
.modal-actions { display: flex; gap: 20rpx; }
.modal-btn {
  flex: 1;
  text-align: center;
  padding: 20rpx;
  border-radius: 16rpx;
  font-size: 28rpx;
}
.modal-btn.cancel { color: rgba(255,255,255,0.45); }
.modal-btn.confirm {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: #fff;
  border: 1rpx solid rgba(139, 92, 246, 0.3);
}
</style>
