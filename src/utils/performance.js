export const getPerformanceProfile = () => {
  if (typeof window === 'undefined') {
    return {
      prefersReducedMotion: false,
      lowEndDevice: false,
    };
  }

  const prefersReducedMotion = window.matchMedia?.('(prefers-reduced-motion: reduce)').matches ?? false;
  const saveData = navigator.connection?.saveData ?? false;
  const deviceMemory = navigator.deviceMemory ?? 8;
  const hardwareConcurrency = navigator.hardwareConcurrency ?? 8;

  const lowEndDevice =
    saveData || deviceMemory <= 4 || hardwareConcurrency <= 4;

  return {
    prefersReducedMotion,
    lowEndDevice,
  };
};
