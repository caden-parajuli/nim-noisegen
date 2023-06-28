import vmath
import random

type
  Noise* {.requiresInit.} = ref object of RootObj
    seed*: int64
    rand*: Rand
  Noise2D* {.requiresInit.} = ref object of Noise
  Noise3D* {.requiresInit.} = ref object of Noise

method noise(noise: Noise2D, pos: DVec2): float64 {.base.} =
  return 0.0

method noise(noise: Noise3D, pos: DVec3): float64 {.base.} =
  return 0.0


proc initNoise*(noise: Noise, seed: int64 = 0) =
  let
    rand = if seed != 0: initRand(seed) else: initRand()
  noise.seed = seed
  noise.rand = rand
