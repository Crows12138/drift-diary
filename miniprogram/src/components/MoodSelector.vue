<template>
  <view class="mood-selector">
    <view class="mood-title">今天的心情</view>
    <view class="mood-list">
      <view
        v-for="mood in MOODS"
        :key="mood.key"
        class="mood-item"
        :class="{ active: selected === mood.key }"
        :style="selected === mood.key ? { borderColor: mood.color + '40', backgroundColor: mood.color + '12' } : {}"
        @tap="$emit('update:selected', mood.key)"
      >
        <text class="mood-emoji">{{ mood.emoji }}</text>
        <text class="mood-label" :style="selected === mood.key ? { color: mood.color } : {}">
          {{ mood.label }}
        </text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { MOODS } from '@/utils/mood'

defineProps<{
  selected: string
}>()

defineEmits<{
  'update:selected': [value: string]
}>()
</script>

<style lang="scss" scoped>
.mood-selector {
  padding: 20rpx 0;
}
.mood-title {
  font-size: 28rpx;
  color: rgba(255,255,255,0.4);
  margin-bottom: 20rpx;
}
.mood-list {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}
.mood-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16rpx 20rpx;
  border-radius: 20rpx;
  border: 2rpx solid rgba(255,255,255,0.08);
  background: rgba(255,255,255,0.06);
  min-width: 100rpx;
  transition: all 0.2s;
  box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.2);
}
.mood-item.active {
  transform: scale(1.05);
}
.mood-emoji {
  font-size: 40rpx;
  margin-bottom: 8rpx;
}
.mood-label {
  font-size: 22rpx;
  color: rgba(255,255,255,0.45);
}
</style>
