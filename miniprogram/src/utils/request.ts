import { API_BASE_URL } from './config'

interface RequestOptions {
  url: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  data?: any
  showError?: boolean
}

function getToken(): string {
  return uni.getStorageSync('token') || ''
}

export function setToken(token: string) {
  uni.setStorageSync('token', token)
}

export function clearToken() {
  uni.removeStorageSync('token')
}

export function request<T = any>(options: RequestOptions): Promise<T> {
  return new Promise((resolve, reject) => {
    uni.request({
      url: `${API_BASE_URL}${options.url}`,
      method: options.method || 'GET',
      data: options.data,
      header: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${getToken()}`
      },
      success: (res: any) => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(res.data as T)
        } else if (res.statusCode === 401) {
          clearToken()
          uni.reLaunch({ url: '/pages/index/index' })
          reject(new Error('登录已过期'))
        } else {
          const msg = res.data?.detail || '请求失败'
          if (options.showError !== false) {
            uni.showToast({ title: msg, icon: 'none' })
          }
          reject(new Error(msg))
        }
      },
      fail: (err: any) => {
        uni.showToast({ title: '网络错误', icon: 'none' })
        reject(err)
      }
    })
  })
}

// 快捷方法
export const api = {
  get: <T = any>(url: string) => request<T>({ url, method: 'GET' }),
  post: <T = any>(url: string, data?: any) => request<T>({ url, method: 'POST', data }),
  delete: <T = any>(url: string) => request<T>({ url, method: 'DELETE' }),
}
