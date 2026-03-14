<template>
  <view class="page safe-area-top">
    <view class="header">
      <text class="page-title">我的</text>
    </view>

    <!-- 统计卡片 -->
    <view class="stats-row">
      <view class="glass-light stat-card">
        <text class="stat-number">{{ stats.totalDiaries }}</text>
        <text class="stat-label">日记</text>
      </view>
      <view class="glass-light stat-card">
        <text class="stat-number">{{ stats.driftCount }}</text>
        <text class="stat-label">漂流瓶</text>
      </view>
      <view class="glass-light stat-card">
        <text class="stat-number">{{ stats.totalResponses }}</text>
        <text class="stat-label">收到回应</text>
      </view>
    </view>

    <!-- 日记列表 -->
    <view class="section">
      <text class="section-title">全部日记</text>
      <view v-if="diaries.length === 0" class="glass-light empty-tip">
        <text class="empty-text">还没有日记</text>
      </view>
      <view v-else class="diary-list">
        <view
          v-for="diary in diaries"
          :key="diary.id"
          class="glass-light diary-item"
          @tap="viewDiary(diary)"
        >
          <view class="diary-item-left">
            <text class="diary-mood">{{ getMoodEmoji(diary.mood_tag) }}</text>
            <view class="diary-info">
              <text class="diary-preview">{{ diary.content.slice(0, 30) }}...</text>
              <text class="diary-meta">{{ formatDate(diary.created_at) }} · {{ diary.type === 'drift' ? '漂流中' : '私密' }}</text>
            </view>
          </view>
          <text class="diary-arrow">›</text>
        </view>
      </view>

      <!-- 加载更多 -->
      <view v-if="hasMore" class="load-more" @tap="loadMore">
        <text class="load-more-text">加载更多</text>
      </view>
    </view>

    <!-- 设置项 -->
    <view class="settings-section">
      <view class="glass setting-item" @tap="clearLogin">
        <text class="setting-text">退出登录</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { api } from '@/utils/request'
import { clearToken } from '@/utils/request'
import { getMood } from '@/utils/mood'

const diaries = ref<any[]>([])
const page = ref(1)
const hasMore = ref(false)
const stats = ref({ totalDiaries: 0, driftCount: 0, totalResponses: 0 })

function getMoodEmoji(key: string) {
  return getMood(key).emoji
}

function formatDate(dateStr: string) {
  const d = new Date(dateStr)
  return `${d.getFullYear()}/${d.getMonth() + 1}/${d.getDate()}`
}

async function loadDiaries(reset = false) {
  if (reset) {
    page.value = 1
    diaries.value = []
  }
  try {
    const data = await api.get<{ items: any[]; total: number }>(
      `/api/diaries?page=${page.value}&page_size=20`
    )
    diaries.value = reset ? data.items : [...diaries.value, ...data.items]
    hasMore.value = diaries.value.length < data.total
    stats.value.totalDiaries = data.total

    // 统计漂流瓶数量
    const bottles = await api.get<any[]>('/api/drift/mine')
    stats.value.driftCount = bottles.length
    stats.value.totalResponses = bottles.reduce(
      (sum: number, b: any) => sum + b.current_station, 0
    )
  } catch (e) {
    console.error('加载失败', e)
  }
}

function loadMore() {
  page.value++
  loadDiaries()
}

function viewDiary(diary: any) {
  uni.navigateTo({ url: `/pages/ai-result/ai-result?diaryId=${diary.id}` })
}

function clearLogin() {
  uni.showModal({
    title: '确认退出',
    content: '退出后需要重新登录',
    success: (res) => {
      if (res.confirm) {
        clearToken()
        uni.reLaunch({ url: '/pages/index/index' })
      }
    }
  })
}

onShow(() => {
  loadDiaries(true)
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
.stats-row {
  display: flex;
  gap: 16rpx;
  margin-bottom: 40rpx;
}
.stat-card {
  flex: 1;
  padding: 28rpx 20rpx;
  text-align: center;
}
.stat-number { font-size: 40rpx; font-weight: 700; color: #818cf8; display: block; }
.stat-label { font-size: 24rpx; color: rgba(255,255,255,0.4); margin-top: 8rpx; display: block; }
.section { margin-bottom: 32rpx; }
.section-title { font-size: 28rpx; color: rgba(255,255,255,0.4); margin-bottom: 20rpx; display: block; }
.empty-tip { text-align: center; padding: 40rpx; }
.empty-text { color: rgba(255,255,255,0.25); font-size: 28rpx; }
.diary-list { display: flex; flex-direction: column; gap: 16rpx; }
.diary-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx;
}
.diary-item-left { display: flex; align-items: center; gap: 16rpx; flex: 1; }
.diary-mood { font-size: 36rpx; }
.diary-info { flex: 1; }
.diary-preview { font-size: 28rpx; color: rgba(255,255,255,0.55); display: block; }
.diary-meta { font-size: 22rpx; color: rgba(255,255,255,0.25); margin-top: 4rpx; display: block; }
.diary-arrow { font-size: 32rpx; color: rgba(255,255,255,0.15); }
.load-more { text-align: center; padding: 24rpx; }
.load-more-text { color: #818cf8; font-size: 26rpx; }
.settings-section {
  margin-top: 40rpx;
}
.setting-item { padding: 24rpx; text-align: center; }
.setting-text { font-size: 28rpx; color: #ef4444; }
</style>
