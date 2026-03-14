<template>
  <view class="page safe-area-top" :style="'background:' + ambientGradient">
    <view class="nav-bar">
      <text class="nav-back" @tap="goBack">← 返回</text>
      <text class="nav-title">AI 分析</text>
      <view style="width: 80rpx;" />
    </view>

    <view v-if="loading" class="loading">
      <text class="loading-text">AI 正在阅读你的日记...</text>
    </view>

    <view v-else class="result">
      <!-- 情绪卡片 -->
      <view class="glass mood-card">
        <text class="mood-emoji">{{ moodEmoji }}</text>
        <view class="mood-info">
          <text class="mood-label">{{ moodLabel }}</text>
          <view class="intensity-bar">
            <view class="intensity-fill" :style="{ width: `${intensity * 10}%`, backgroundColor: moodColor }" />
          </view>
          <text class="intensity-text">情绪强度 {{ intensity }}/10</text>
        </view>
      </view>

      <!-- AI 回应 -->
      <view class="glass-light ai-response">
        <text class="ai-icon">🤖</text>
        <text class="ai-text">{{ summary }}</text>
      </view>

      <!-- 关键词 -->
      <view v-if="keywords.length" class="keywords">
        <text class="keywords-title">关键词</text>
        <view class="keywords-list">
          <text v-for="(kw, i) in keywords" :key="i" class="keyword-tag">{{ kw }}</text>
        </view>
      </view>

      <!-- 操作按钮 -->
      <view class="actions">
        <view class="glass action-btn" @tap="goHome">
          <text>返回首页</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { api } from '@/utils/request'
import { getMood } from '@/utils/mood'

const loading = ref(true)
const summary = ref('')
const intensity = ref(5)
const keywords = ref<string[]>([])
const moodEmoji = ref('😌')
const moodLabel = ref('平静')
const moodColor = ref('#818cf8')

const ambientGradient = computed(() => {
  const hex = moodColor.value
  const r = parseInt(hex.slice(1, 3), 16)
  const g = parseInt(hex.slice(3, 5), 16)
  const b = parseInt(hex.slice(5, 7), 16)
  return `radial-gradient(circle at 30% 0%, rgba(${r},${g},${b},0.55) 0%, transparent 50%), radial-gradient(circle at 80% 100%, rgba(${r},${g},${b},0.2) 0%, transparent 40%), #0a0e27`
})

let diaryId = 0

onLoad((query: any) => {
  diaryId = parseInt(query.diaryId || '0')
  if (query.mood) {
    const m = getMood(query.mood)
    moodEmoji.value = m.emoji
    moodLabel.value = m.label
    moodColor.value = m.color
  }
  loadDiary()
})

async function loadDiary() {
  try {
    const diary = await api.get<any>(`/api/diaries/${diaryId}`)
    if (diary.ai_analysis) {
      applyAnalysis(diary.ai_analysis)
    } else {
      // 请求 AI 分析
      const analysis = await api.post<any>('/api/ai/analyze', { content: diary.content })
      applyAnalysis(analysis)
    }
  } catch (e) {
    summary.value = '加载失败，请稍后再试'
  } finally {
    loading.value = false
  }
}

function applyAnalysis(data: any) {
  const m = getMood(data.mood || 'calm')
  moodEmoji.value = m.emoji
  moodLabel.value = m.label
  moodColor.value = m.color
  intensity.value = data.intensity || 5
  summary.value = data.summary || ''
  keywords.value = data.keywords || []
}

function goBack() {
  uni.navigateBack()
}

function goHome() {
  uni.switchTab({ url: '/pages/index/index' })
}
</script>

<style lang="scss" scoped>
.page {
  padding: 0 32rpx;
  min-height: 100vh;
}

/* 氛围光通过 page backgroundImage 动态设置 */

.nav-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 40rpx 0 20rpx;
}
.nav-back { font-size: 28rpx; color: #818cf8; width: 80rpx; }
.nav-title { font-size: 32rpx; color: #e8ecf4; font-weight: 600; }
.loading {
  display: flex;
  justify-content: center;
  padding: 200rpx 0;
}
.loading-text { color: rgba(255,255,255,0.4); font-size: 30rpx; }
.mood-card {
  display: flex;
  align-items: center;
  gap: 24rpx;
  padding: 32rpx;
  margin: 32rpx 0;
  border-left: 6rpx solid;
  border-left-color: v-bind(moodColor);
}
.mood-emoji { font-size: 64rpx; }
.mood-info { flex: 1; }
.mood-label { font-size: 32rpx; color: #e8ecf4; font-weight: 600; display: block; margin-bottom: 12rpx; }
.intensity-bar {
  width: 100%;
  height: 12rpx;
  background: rgba(255,255,255,0.08);
  border-radius: 6rpx;
  overflow: hidden;
  margin-bottom: 8rpx;
}
.intensity-fill {
  height: 100%;
  border-radius: 6rpx;
  transition: width 0.5s ease;
}
.intensity-text { font-size: 22rpx; color: rgba(255,255,255,0.35); }
.ai-response {
  display: flex;
  gap: 16rpx;
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.ai-icon { font-size: 36rpx; flex-shrink: 0; }
.ai-text { font-size: 28rpx; color: rgba(255,255,255,0.6); line-height: 1.8; }
.keywords { margin-bottom: 32rpx; }
.keywords-title { font-size: 26rpx; color: rgba(255,255,255,0.4); margin-bottom: 16rpx; display: block; }
.keywords-list { display: flex; flex-wrap: wrap; gap: 12rpx; }
.keyword-tag {
  font-size: 24rpx;
  color: #818cf8;
  background: rgba(129,140,248,0.15);
  padding: 8rpx 24rpx;
  border-radius: 20rpx;
}
.actions { padding: 40rpx 0; }
.action-btn {
  text-align: center;
  padding: 24rpx;
  color: rgba(255,255,255,0.45);
  font-size: 28rpx;
}
</style>
