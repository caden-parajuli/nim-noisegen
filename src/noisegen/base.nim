import random

type
  Noise* {.requiresInit.} = ref object of RootObj
    seed*: int64
    rand*: Rand


method initNoise*(noise: Noise, seed: int64 = 0) =
  let
    rand = if seed != 0: initRand(seed) else: initRand()
  noise.seed = seed
  noise.rand = rand

proc lerp*(a, b, x: float64): float64 =
    return a + x * (b - a);