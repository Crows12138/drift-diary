export interface MoodOption {
  key: string
  emoji: string
  label: string
  color: string
}

export const MOODS: MoodOption[] = [
  { key: 'happy', emoji: '😊', label: '开心', color: '#fbbf24' },
  { key: 'calm', emoji: '😌', label: '平静', color: '#818cf8' },
  { key: 'anxious', emoji: '😰', label: '焦虑', color: '#fbbf24' },
  { key: 'sad', emoji: '😢', label: '难过', color: '#a78bfa' },
  { key: 'angry', emoji: '😤', label: '愤怒', color: '#f87171' },
  { key: 'confused', emoji: '😶‍🌫️', label: '迷茫', color: '#94a3b8' },
  { key: 'grateful', emoji: '🥰', label: '感恩', color: '#fb923c' },
]

export function getMood(key: string): MoodOption {
  return MOODS.find(m => m.key === key) || MOODS[1]
}
