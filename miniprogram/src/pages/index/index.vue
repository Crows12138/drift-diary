<template>
  <view class="page safe-area-top" :style="'background:' + ambientGradient">

    <!-- 头部 -->
    <view class="header">
      <view class="date-section">
        <text class="date-day">{{ todayDay }}</text>
        <view class="date-info">
          <text class="date-month">{{ todayMonth }}</text>
          <text class="date-weekday">{{ todayWeekday }}</text>
        </view>
      </view>
    </view>

    <text class="greeting">{{ greeting }}</text>

    <!-- 写日记 -->
    <view class="glass write-btn" @tap="goWrite">
      <view class="write-left">
        <text class="write-icon">✏️</text>
        <view class="write-info">
          <text class="write-text">写下今天的故事</text>
          <text class="write-hint">记录此刻的心情</text>
        </view>
      </view>
      <text class="write-arrow">›</text>
    </view>

    <!-- 今日灵感 -->
    <view class="glass-light prompt-card" @tap="goWriteWithPrompt">
      <text class="prompt-label">💡 今日灵感</text>
      <text class="prompt-text">{{ dailyPrompt }}</text>
      <text class="prompt-action">点击开始写 →</text>
    </view>

    <!-- 漂流瓶海域 -->
    <view class="glass-light drift-preview">
      <view class="drift-header">
        <text class="section-title">🌊 漂流瓶海域</text>
        <text class="drift-more" @tap="goDrift">去捡瓶子 →</text>
      </view>
      <view class="drift-stats">
        <view class="drift-stat-item">
          <text class="drift-stat-num">{{ driftTotal }}</text>
          <text class="drift-stat-label">瓶子在漂流</text>
        </view>
        <view class="drift-stat-divider" />
        <view class="drift-stat-item">
          <text class="drift-stat-num">{{ driftResponded }}</text>
          <text class="drift-stat-label">今日被回应</text>
        </view>
        <view class="drift-stat-divider" />
        <view class="drift-stat-item">
          <text class="drift-stat-num">{{ driftLongest }}</text>
          <text class="drift-stat-label">最长旅程(站)</text>
        </view>
      </view>
      <view class="drift-wave-inner">
        <text class="wave-text">🍾 有人刚刚投出了一个漂流瓶...</text>
      </view>
    </view>

    <!-- 最近日记 -->
    <view class="section">
      <text class="section-title">📖 最近的日记</text>
      <view v-if="diaries.length === 0" class="glass-light empty-tip">
        <text class="empty-text">写下第一篇日记，开始你的漂流之旅</text>
      </view>
      <view v-else class="diary-list">
        <view
          v-for="diary in diaries"
          :key="diary.id"
          class="glass-light diary-card"
          @tap="viewDiary(diary)"
        >
          <view class="diary-card-header">
            <text class="diary-mood">{{ getMoodEmoji(diary.mood_tag) }}</text>
            <text class="diary-date">{{ formatDate(diary.created_at) }}</text>
            <text v-if="diary.type === 'drift'" class="diary-drift-badge">🍾 漂流中</text>
          </view>
          <text class="diary-content">{{ diary.content.slice(0, 80) }}{{ diary.content.length > 80 ? '...' : '' }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { api } from '@/utils/request'
import { getMood } from '@/utils/mood'

const diaries = ref<any[]>([])
const driftTotal = ref(0)
const driftResponded = ref(0)
const driftLongest = ref(0)

// 当前心情色（默认平静色，写日记后会根据最近心情变化）
const moodColor = ref('#818cf8') // 默认靛蓝

// 双光球氛围光
const ambientGradient = computed(() => {
  const hex = moodColor.value
  const r = parseInt(hex.slice(1, 3), 16)
  const g = parseInt(hex.slice(3, 5), 16)
  const b = parseInt(hex.slice(5, 7), 16)
  return `radial-gradient(circle at 30% 0%, rgba(${r},${g},${b},0.55) 0%, transparent 50%), radial-gradient(circle at 80% 100%, rgba(${r},${g},${b},0.2) 0%, transparent 40%), #0a0e27`
})

// 心情色映射
const MOOD_COLORS: Record<string, string> = {
  happy: '#fbbf24',
  calm: '#818cf8',
  anxious: '#fbbf24',
  sad: '#a78bfa',
  angry: '#f87171',
  confused: '#94a3b8',
  grateful: '#fb923c',
}

const now = new Date()
const hour = now.getHours()
const monthNames = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月']
const weekNames = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
const todayDay = ref(now.getDate())
const todayMonth = ref(monthNames[now.getMonth()])
const todayWeekday = ref(weekNames[now.getDay()])
const greeting = ref(
  hour < 6 ? '夜深了，有什么心事想记录吗？'
  : hour < 12 ? '早上好，新的一天开始了'
  : hour < 14 ? '中午好，忙碌的间隙歇一歇'
  : hour < 18 ? '下午好，今天过得怎么样？'
  : hour < 22 ? '晚上好，回顾一下今天吧'
  : '夜深了，有什么心事想记录吗？'
)

const ALL_PROMPTS = [
  '今天让你微笑的一件小事是什么？',
  '如果今天的心情是一种天气，会是什么？',
  '此刻最想对谁说一句话？',
  '今天学到了什么新东西？',
  '用三个词形容你现在的状态',
  '如果可以重来今天，你会改变什么？',
  '最近有什么事一直放在心里没说？',
  '今天做的最勇敢的一件事是什么？',
  '你最近最感恩的一件事是什么？',
  '如果给今天打分1到10分，你会打几分？',
  '最近有什么让你觉得还好有这个人的时刻？',
  '你现在最期待的一件事是什么？',
]
const dayOfYear = Math.floor((Date.now() - new Date(now.getFullYear(), 0, 0).getTime()) / 86400000)
const dailyPrompt = ref(ALL_PROMPTS[dayOfYear % ALL_PROMPTS.length])

function getMoodEmoji(key: string) {
  return getMood(key).emoji
}

function formatDate(dateStr: string) {
  const d = new Date(dateStr)
  return `${d.getMonth() + 1}/${d.getDate()} ${d.getHours()}:${String(d.getMinutes()).padStart(2, '0')}`
}

async function loadDiaries() {
  try {
    const data = await api.get<{ items: any[]; total: number }>('/api/diaries?page=1&page_size=10')
    diaries.value = data.items
    if (data.items.length > 0) {
      const latestMood = data.items[0].mood_tag
      moodColor.value = MOOD_COLORS[latestMood] || '#6366f1'
    }
  } catch (e) {
    console.error('加载日记失败', e)
  }
}

async function loadDriftStats() {
  try {
    const bottles = await api.get<any[]>('/api/drift/mine')
    driftTotal.value = bottles.length
    driftResponded.value = bottles.filter((b: any) => b.current_station > 0).length
    driftLongest.value = bottles.reduce((max: number, b: any) => Math.max(max, b.current_station), 0)
  } catch {
    // 静默失败
  }
}

function goWrite() {
  uni.navigateTo({ url: '/pages/write/write' })
}

function goWriteWithPrompt() {
  uni.navigateTo({ url: `/pages/write/write?prompt=${encodeURIComponent(dailyPrompt.value)}` })
}

function goDrift() {
  uni.switchTab({ url: '/pages/drift/drift' })
}

function viewDiary(diary: any) {
  uni.navigateTo({ url: `/pages/ai-result/ai-result?diaryId=${diary.id}` })
}

onShow(() => {
  loadDiaries()
  loadDriftStats()
})
</script>

<style lang="scss" scoped>
.page {
  padding: 40rpx 32rpx;
  padding-bottom: 120rpx;
  min-height: 100vh;
}

/* ===== 头部 ===== */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 40rpx;
  margin-bottom: 12rpx;
}
.date-section { display: flex; align-items: center; gap: 16rpx; }
.date-day {
  font-size: 72rpx;
  font-weight: 700;
  color: #ffffff;
  line-height: 1;
}
.date-info { display: flex; flex-direction: column; }
.date-month { font-size: 24rpx; color: rgba(255,255,255,0.5); }
.date-weekday { font-size: 24rpx; color: #818cf8; }

.greeting {
  font-size: 28rpx;
  color: rgba(255,255,255,0.45);
  display: block;
  margin-bottom: 36rpx;
}

/* ===== 写日记按钮 ===== */
.write-btn {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 36rpx 32rpx;
  margin-bottom: 24rpx;
}
.write-left { display: flex; align-items: center; gap: 20rpx; }
.write-icon { font-size: 40rpx; }
.write-info { display: flex; flex-direction: column; }
.write-text { font-size: 30rpx; color: #e8ecf4; font-weight: 500; }
.write-hint { font-size: 22rpx; color: rgba(255,255,255,0.35); margin-top: 6rpx; }
.write-arrow { font-size: 44rpx; color: rgba(255,255,255,0.2); }

/* ===== 灵感卡片 ===== */
.prompt-card {
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.prompt-label {
  font-size: 24rpx;
  color: #818cf8;
  display: block;
  margin-bottom: 14rpx;
}
.prompt-text {
  font-size: 30rpx;
  color: #e8ecf4;
  line-height: 1.7;
  display: block;
  margin-bottom: 16rpx;
}
.prompt-action {
  font-size: 24rpx;
  color: #a78bfa;
}

/* ===== 漂流瓶海域 ===== */
.drift-preview {
  padding: 28rpx;
  margin-bottom: 32rpx;
}
.drift-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}
.drift-more { font-size: 24rpx; color: #818cf8; }
.drift-stats {
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding: 16rpx 0;
  margin-bottom: 16rpx;
}
.drift-stat-item { text-align: center; }
.drift-stat-num {
  font-size: 44rpx;
  font-weight: 700;
  color: #ffffff;
  display: block;
}
.drift-stat-label {
  font-size: 20rpx;
  color: rgba(255,255,255,0.4);
  margin-top: 6rpx;
  display: block;
}
.drift-stat-divider {
  width: 1rpx;
  height: 48rpx;
  background: rgba(255,255,255,0.1);
}
.drift-wave-inner {
  background: rgba(255,255,255,0.04);
  border-radius: 14rpx;
  padding: 16rpx 20rpx;
}
.wave-text { font-size: 24rpx; color: rgba(255,255,255,0.35); }

/* ===== 日记列表 ===== */
.section { margin-bottom: 32rpx; }
.section-title {
  font-size: 28rpx;
  color: rgba(255,255,255,0.4);
  margin-bottom: 20rpx;
  display: block;
}

.empty-tip {
  padding: 48rpx;
  text-align: center;
}
.empty-text { color: rgba(255,255,255,0.35); font-size: 26rpx; }

.diary-list { display: flex; flex-direction: column; gap: 16rpx; }
.diary-card { padding: 24rpx; }
.diary-card-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 12rpx;
}
.diary-mood { font-size: 32rpx; }
.diary-date { font-size: 24rpx; color: rgba(255,255,255,0.3); }
.diary-drift-badge {
  font-size: 22rpx;
  color: #818cf8;
  background: rgba(129,140,248,0.15);
  padding: 4rpx 16rpx;
  border-radius: 20rpx;
  margin-left: auto;
}
.diary-content {
  font-size: 28rpx;
  color: rgba(255,255,255,0.55);
  line-height: 1.6;
}
</style>
