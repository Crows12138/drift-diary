import { api, setToken } from './request'

/** 微信登录 */
export async function wxLogin() {
  return new Promise<void>((resolve, reject) => {
    uni.login({
      provider: 'weixin',
      success: async (loginRes) => {
        try {
          const data = await api.post<{ access_token: string }>('/api/auth/wx-login', {
            code: loginRes.code,
          })
          setToken(data.access_token)
          resolve()
        } catch (e) {
          reject(e)
        }
      },
      fail: reject,
    })
  })
}

/** 开发环境测试登录 */
export async function devLogin(testUserId: string = 'test_user_1') {
  const data = await api.post<{ access_token: string }>('/api/auth/dev-login', {
    test_user_id: testUserId,
  })
  setToken(data.access_token)
}
