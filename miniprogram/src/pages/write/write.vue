<template>
  <view class="page safe-area-top">
    <view class="nav-bar">
      <text class="nav-back" @tap="goBack">← 返回</text>
      <text class="nav-title">写日记</text>
      <view style="width: 80rpx;" />
    </view>

    <!-- 写作灵感提示 -->
    <view v-if="prompt" class="glass-light prompt-hint">
      <text class="prompt-hint-label">💡 今日灵感</text>
      <text class="prompt-hint-text">{{ prompt }}</text>
    </view>

    <!-- 日记内容 -->
    <view class="editor-section">
      <textarea
        v-model="content"
        class="glass editor"
        :placeholder="prompt || '写下今天的故事...'"
        placeholder-style="color: rgba(255,255,255,0.25)"
        :maxlength="5000"
        auto-height
        :focus="true"
      />
      <text class="word-count">{{ content.length }} / 5000</text>
    </view>

    <!-- 主题标签 -->
    <view class="tags-section">
      <text class="tags-label">主题标签（可选）</text>
      <view class="tags-input-row">
        <input
          v-model="tagInput"
          class="glass tag-input"
          placeholder="输入标签，按回车添加"
          placeholder-style="color: rgba(255,255,255,0.25)"
          @confirm="addTag"
        />
      </view>
      <view v-if="topicTags.length" class="tags-list">
        <view v-for="(tag, i) in topicTags" :key="i" class="tag-item">
          <text class="tag-text">#{{ tag }}</text>
          <text class="tag-remove" @tap="removeTag(i)">×</text>
        </view>
      </view>
    </view>

    <!-- 提交按钮 -->
    <view class="submit-section safe-area-bottom">
      <view class="glass submit-btn private" @tap="submit('private')" :class="{ disabled: submitting }">
        <text>🔒 仅自己可见</text>
      </view>
      <view class="submit-btn drift" @tap="submit('drift')" :class="{ disabled: submitting }">
        <text>🍾 放入漂流瓶</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { api } from '@/utils/request'

const content = ref('')
const topicTags = ref<string[]>([])
const tagInput = ref('')
const submitting = ref(false)
const prompt = ref('')

onLoad((query: any) => {
  if (query?.prompt) {
    prompt.value = decodeURIComponent(query.prompt)
  }
})

function goBack() {
  uni.navigateBack()
}

function addTag() {
  const tag = tagInput.value.trim().replace(/^#/, '')
  if (tag && !topicTags.value.includes(tag) && topicTags.value.length < 5) {
    topicTags.value.push(tag)
  }
  tagInput.value = ''
}

function removeTag(index: number) {
  topicTags.value.splice(index, 1)
}

async function submit(type: 'private' | 'drift') {
  if (!content.value.trim()) {
    uni.showToast({ title: '写点什么吧', icon: 'none' })
    return
  }
  if (submitting.value) return
  submitting.value = true

  try {
    const diary = await api.post<any>('/api/diaries', {
      content: content.value.trim(),
      mood_tag: 'calm',
      topic_tags: topicTags.value.length ? topicTags.value : null,
      type,
    })

    // 触发 AI 分析
    try {
      const analysis = await api.post<any>('/api/ai/analyze', {
        content: content.value.trim(),
      })
      diary.ai_analysis = analysis
    } catch (e) {
      console.error('AI 分析失败', e)
    }

    uni.showToast({
      title: type === 'drift' ? '漂流瓶已投出 🍾' : '日记已保存 ✨',
      icon: 'none',
    })

    // 跳转到 AI 分析结果页
    setTimeout(() => {
      uni.redirectTo({
        url: `/pages/ai-result/ai-result?diaryId=${diary.id}&mood=${moodTag.value}&isNew=1`,
      })
    }, 500)
  } catch (e) {
    uni.showToast({ title: '保存失败', icon: 'none' })
  } finally {
    submitting.value = false
  }
}
</script>

<style lang="scss" scoped>
.page {
  padding: 0 32rpx;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}
.nav-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 40rpx 0 20rpx;
}
.nav-back {
  font-size: 28rpx;
  color: #818cf8;
  width: 80rpx;
}
.nav-title {
  font-size: 32rpx;
  color: #e8ecf4;
  font-weight: 600;
}
.prompt-hint {
  padding: 20rpx 24rpx;
  margin: 12rpx 0;
}
.prompt-hint-label { font-size: 22rpx; color: #818cf8; display: block; margin-bottom: 8rpx; }
.prompt-hint-text { font-size: 28rpx; color: rgba(255,255,255,0.5); line-height: 1.6; font-style: italic; }
.editor-section {
  flex: 1;
  margin: 20rpx 0;
}
.editor {
  width: 100%;
  min-height: 300rpx;
  padding: 28rpx;
  font-size: 30rpx;
  color: rgba(255,255,255,0.85);
  line-height: 1.8;
}
.word-count {
  display: block;
  text-align: right;
  font-size: 22rpx;
  color: rgba(255,255,255,0.25);
  margin-top: 8rpx;
}
.tags-section {
  margin-bottom: 24rpx;
}
.tags-label {
  font-size: 28rpx;
  color: rgba(255,255,255,0.4);
  margin-bottom: 12rpx;
  display: block;
}
.tags-input-row { margin-bottom: 12rpx; }
.tag-input {
  padding: 16rpx 24rpx;
  font-size: 28rpx;
  color: rgba(255,255,255,0.85);
}
.tags-list { display: flex; flex-wrap: wrap; gap: 12rpx; }
.tag-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
  background: rgba(129, 140, 248, 0.15);
  border-radius: 20rpx;
  padding: 8rpx 20rpx;
}
.tag-text { font-size: 24rpx; color: #818cf8; }
.tag-remove { font-size: 28rpx; color: #818cf8; }
.submit-section {
  display: flex;
  gap: 20rpx;
  padding: 24rpx 0 40rpx;
}
.submit-btn {
  flex: 1;
  text-align: center;
  padding: 24rpx;
  border-radius: 20rpx;
  font-size: 28rpx;
  font-weight: 500;
}
.submit-btn.private {
  color: rgba(255,255,255,0.45);
}
.submit-btn.drift {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1rpx solid rgba(139, 92, 246, 0.3);
  color: #fff;
}
.submit-btn.disabled { opacity: 0.5; }
</style>
