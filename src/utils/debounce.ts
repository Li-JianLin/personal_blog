/**
 * 防抖函数
 * @param func 要防抖的函数
 * @param delay 延迟时间（毫秒）
 * @returns 防抖后的函数
 */
export const debounce = <T extends (...args: unknown[]) => void>(func: T, delay: number) => {
  let timeoutId: ReturnType<typeof setTimeout> | null = null

  return (...args: Parameters<T>) => {
    if (timeoutId) clearTimeout(timeoutId)
    timeoutId = setTimeout(() => func(...args), delay)
  }
}

/**
 * 节流函数
 * @param func 要节流的函数
 * @param delay 节流间隔时间（毫秒）
 * @returns 节流后的函数
 */
export const throttle = <T extends (...args: unknown[]) => void>(func: T, delay: number) => {
  let timeoutId: ReturnType<typeof setTimeout> | null = null
  let lastExecTime = 0

  return (...args: Parameters<T>) => {
    const currentTime = Date.now()

    if (currentTime - lastExecTime > delay) {
      func(...args)
      lastExecTime = currentTime
    } else {
      if (timeoutId) clearTimeout(timeoutId)
      timeoutId = setTimeout(
        () => {
          func(...args)
          lastExecTime = Date.now()
        },
        delay - (currentTime - lastExecTime),
      )
    }
  }
}

/**
 * 防抖函数（立即执行版本）
 * 第一次调用立即执行，后续调用在指定时间内会被防抖
 * @param func 要防抖的函数
 * @param delay 延迟时间（毫秒）
 * @returns 防抖后的函数
 */
export const debounceImmediate = <T extends (...args: unknown[]) => void>(
  func: T,
  delay: number,
) => {
  let timeoutId: ReturnType<typeof setTimeout> | null = null
  let isFirstCall = true

  return (...args: Parameters<T>) => {
    if (isFirstCall) {
      func(...args)
      isFirstCall = false
    } else {
      if (timeoutId) clearTimeout(timeoutId)
      timeoutId = setTimeout(() => {
        func(...args)
        isFirstCall = true
      }, delay)
    }
  }
}

/**
 * 简单节流函数（性能优化版本）
 * @param func 要节流的函数
 * @param delay 节流间隔时间（毫秒）
 * @returns 节流后的函数
 */
export const simpleThrottle = <T extends (...args: unknown[]) => void>(func: T, delay: number) => {
  let lastExecTime = 0

  return (...args: Parameters<T>) => {
    const currentTime = Date.now()
    if (currentTime - lastExecTime > delay) {
      func(...args)
      lastExecTime = currentTime
    }
  }
}
