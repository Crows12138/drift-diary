<template>
  <view class="page safe-area-top">
    <view class="header">
      <text class="page-title">漂流瓶</text>
    </view>

    <!-- 捡漂流瓶 -->
    <view class="pick-section">
      <view class="pick-btn" @tap="pickBottle" :class="{ disabled: picking }">
        <text class="pick-emoji">🍾</text>
        <text class="pick-text">{{ picking ? '正在捡...' : '捡一个漂流瓶' }}</text>
      </view>
    </view>

    <!-- 当前持有的漂流瓶 -->
    <view v-if="currentBottle" class="current-bottle">
      <view class="section-header">
        <text class="section-title">捡到的漂流瓶</text>
        <text class="station-info">已漂流 {{ currentBottle.current_station }} 站</text>
      </view>
      <view class="glass bottle-card">
        <text class="bottle-mood">{{ getMoodEmoji(currentBottle.mood_tag) }}</text>
        <text class="bottle-content">{{ currentBottle.diary_content }}</text>

        <!-- 已有回应 -->
        <view v-if="currentBottle.responses.length" class="responses">
          <view
            v-for="(resp, i) in currentBottle.responses"
            :key="i"
            class="response-item"
          >
            <view class="response-header">
              <text class="response-station">📍 第{{ resp.station_number }}站</text>
              <text class="response-date">{{ formatDate(resp.created_at) }}</text>
            </view>
            <text class="response-content">{{ resp.content }}</text>
          </view>
        </view>

        <!-- 写回应 -->
        <view class="respond-section">
          <textarea
            v-model="responseText"
            class="respond-input"
            placeholder="写下你的回应，然后放回漂流..."
            placeholder-style="color: rgba(255,255,255,0.25)"
            :maxlength="500"
          />
          <view class="respond-actions">
            <text class="respond-count">{{ responseText.length }}/500</text>
            <view class="respond-btn" @tap="sendResponse" :class="{ disabled: !responseText.trim() }">
              <text>放回漂流 🌊</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 我投出的漂流瓶 -->
    <view class="section">
      <text class="section-title">我投出的漂流瓶</text>
      <view v-if="myBottles.length === 0" class="glass-light empty-tip">
        <text class="empty-text">还没有投出过漂流瓶</text>
      </view>
      <view v-else class="bottle-list">
        <view
          v-for="bottle in myBottles"
          :key="bottle.id"
          class="glass-light my-bottle-card"
          @tap="viewJourney(bottle.id)"
        >
          <view class="my-bottle-header">
            <text class="my-bottle-preview">{{ bottle.diary_content_preview }}</text>
            <text v-if="bottle.has_new_response" class="new-badge">新回应</text>
          </view>
          <view class="my-bottle-footer">
            <text class="my-bottle-station">🌊 已漂流 {{ bottle.current_station }} 站</text>
            <text class="my-bottle-status">{{ bottle.status === 'drifting' ? '漂流中' : '被捡起' }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { api } from '@/utils/request'
import { getMood } from '@/utils/mood'

const picking = ref(false)
const currentBottle = ref<any>(null)
const responseText = ref('')
const myBottles = ref<any[]>([])

function getMoodEmoji(key: string) {
  return getMood(key).emoji
}

function formatDate(dateStr: string) {
  const d = new Date(dateStr)
  return `${d.getMonth() + 1}/${d.getDate()}`
}

async function pickBottle() {
  if (picking.value) return
  picking.value = true
  try {
    const bottle = await api.post<any>('/api/drift/pick')
    currentBottle.value = bottle
    responseText.value = ''
  } catch (e: any) {
    if (e.message?.includes('暂时没有')) {
      uni.showToast({ title: '暂时没有漂流瓶，过会再来', icon: 'none' })
    }
  } finally {
    picking.value = false
  }
}

async function sendResponse() {
  if (!responseText.value.trim() || !currentBottle.value) return
  try {
    await api.post(`/api/drift/${currentBottle.value.id}/respond`, {
      content: responseText.value.trim(),
    })
    uni.showToast({ title: '漂流瓶已继续漂流 🌊', icon: 'none' })
    currentBottle.value = null
    responseText.value = ''
    loadMyBottles()
  } catch (e) {
    // 错误已在 request 中处理
  }
}

async function loadMyBottles() {
  try {
    myBottles.value = await api.get<any[]>('/api/drift/mine')
  } catch (e) {
    console.error('加载漂流瓶失败', e)
  }
}

function viewJourney(bottleId: number) {
  uni.navigateTo({ url: `/pages/drift-detail/drift-detail?bottleId=${bottleId}` })
}

onShow(() => {
  loadMyBottles()
})
</script>

<style lang="scss" scoped>
.page {
  padding: 40rpx 32rpx;
  padding-bottom: 120rpx;
  min-height: 100vh;
}
.header {
  padding-top: 40rpx;
  margin-bottom: 32rpx;
}
.page-title {
  font-size: 44rpx;
  font-weight: 700;
  color: #ffffff;
  text-shadow: 0 0 40rpx rgba(129,140,248,0.3);
}
.pick-section {
  margin-bottom: 40rpx;
}
.pick-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16rpx;
  padding: 36rpx;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1rpx solid rgba(139, 92, 246, 0.3);
  border-radius: 24rpx;
  font-size: 32rpx;
  color: #fff;
  font-weight: 600;
}
.pick-btn.disabled { opacity: 0.6; }
.pick-emoji { font-size: 40rpx; }
.pick-text { font-size: 32rpx; }
.current-bottle { margin-bottom: 40rpx; }
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}
.section-title { font-size: 28rpx; color: rgba(255,255,255,0.4); display: block; margin-bottom: 20rpx; }
.station-info { font-size: 24rpx; color: #818cf8; }
.bottle-card {
  padding: 28rpx;
}
.bottle-mood { font-size: 36rpx; display: block; margin-bottom: 16rpx; }
.bottle-content {
  font-size: 30rpx;
  color: rgba(255,255,255,0.65);
  line-height: 1.8;
  display: block;
  margin-bottom: 20rpx;
}
.responses {
  border-top: 1rpx solid rgba(255,255,255,0.08);
  padding-top: 20rpx;
  margin-bottom: 20rpx;
}
.response-item {
  padding: 16rpx 0;
  border-bottom: 1rpx solid rgba(255,255,255,0.05);
}
.response-item:last-child { border-bottom: none; }
.response-header {
  display: flex;
  gap: 12rpx;
  margin-bottom: 8rpx;
}
.response-station { font-size: 24rpx; color: #818cf8; }
.response-date { font-size: 22rpx; color: rgba(255,255,255,0.25); }
.response-content { font-size: 28rpx; color: rgba(255,255,255,0.5); line-height: 1.6; }
.respond-section {
  border-top: 1rpx solid rgba(255,255,255,0.08);
  padding-top: 20rpx;
}
.respond-input {
  width: 100%;
  min-height: 120rpx;
  background: rgba(255,255,255,0.05);
  border-radius: 16rpx;
  padding: 20rpx;
  font-size: 28rpx;
  color: rgba(255,255,255,0.85);
  line-height: 1.6;
  margin-bottom: 12rpx;
  border: 1rpx solid rgba(255,255,255,0.1);
}
.respond-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.respond-count { font-size: 22rpx; color: rgba(255,255,255,0.25); }
.respond-btn {
  padding: 12rpx 32rpx;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  border-radius: 16rpx;
  color: #fff;
  font-size: 26rpx;
  border: 1rpx solid rgba(139, 92, 246, 0.3);
}
.respond-btn.disabled { opacity: 0.4; }
.section { margin-top: 20rpx; }
.empty-tip { padding: 40rpx 0; text-align: center; }
.empty-text { color: rgba(255,255,255,0.25); font-size: 28rpx; }
.bottle-list { display: flex; flex-direction: column; gap: 16rpx; }
.my-bottle-card {
  padding: 24rpx;
}
.my-bottle-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;
}
.my-bottle-preview { font-size: 28rpx; color: rgba(255,255,255,0.55); flex: 1; }
.new-badge {
  font-size: 20rpx;
  color: #f472b6;
  background: rgba(244, 114, 182, 0.15);
  padding: 4rpx 16rpx;
  border-radius: 12rpx;
  flex-shrink: 0;
  margin-left: 12rpx;
}
.my-bottle-footer {
  display: flex;
  justify-content: space-between;
}
.my-bottle-station { font-size: 24rpx; color: #818cf8; }
.my-bottle-status { font-size: 24rpx; color: rgba(255,255,255,0.3); }
</style>
