import vmath
import std/[random]
import base

##[
   Hash lookup table as defined by Ken Perlin. This is a randomly arranged array of all numbers from 0-255 inclusive,
   repeated once to avoid overflow
 ]##

const p: array[512, int] = [151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,      # Repeats after this line
    151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180]

type
  Perlin = ref object of Noise
    repeat: int
  Perlin2D* = ref object of Perlin
  Perlin3D* = ref object of Perlin
    
proc fade(t: float64): float64 =
  ## 6t^5 - 15t^4 + 10t^3
  result = t * t * t * (t * (t * 6 - 15) + 10)

proc inc(noise: Perlin, num: int): int =
  result = num + 1
  if noise.repeat != 0:
    result = result mod noise.repeat

proc newPerlin*(seed: int64 = 0, repeat: int = 0): Perlin =
  result = Perlin(repeat: repeat)
  result.initNoise(seed)

proc newPerlin2D*(seed: int64 = 0, repeat: int = 0): Perlin2D =
  result = Perlin2D()
  result.initNoise(seed)
  result.repeat = repeat

proc newPerlin3D*(seed: int64 = 0, repeat: int = 0): Perlin3D =
  result = Perlin3D()
  result.initNoise(seed)
  result.repeat = repeat

proc grad(hash: int, x, y, z: float64): float64 =
  case (hash and 0xF):
    of 0x0: return  x + y
    of 0x1: return -x + y
    of 0x2: return  x - y
    of 0x3: return -x - y
    of 0x4: return  x + z
    of 0x5: return -x + z
    of 0x6: return  x - z
    of 0x7: return -x - z
    of 0x8: return  y + z
    of 0x9: return -y + z
    of 0xA: return  y - z
    of 0xB: return -y - z
    of 0xC: return  y + x
    of 0xD: return -y + z
    of 0xE: return  y - x
    of 0xF: return -y - z
    else:
      assert(false)
      return 0 # never happens
  
proc noise*(noise: Perlin3D, pos: DVec3): float64 =
  let
    xi = int(pos.x)
    yi = int(pos.y)
    zi = int(pos.z)
  var
    pos = pos
    fracPos: DVec3 = fract(pos)
    u,v,w: float64
    aaa, aba, aab, abb, baa, bba, bab, bbb: int
  if noise.repeat != 0:
    pos.x = zmod(pos.x, noise.repeat.float64)
    pos.y = zmod(pos.y, noise.repeat.float64)
    pos.z = zmod(pos.z, noise.repeat.float64)

  u = fade(fracPos.x)
  v = fade(fracpos.y)
  w = fade(fracPos.z)

  aaa = p[p[p[xi] + yi] + zi]
  aba = p[p[p[xi] + noise.inc(yi)] + zi]
  aab = p[p[p[xi] + yi] + noise.inc(zi)]
  abb = p[p[p[xi] + noise.inc(yi)] + noise.inc(zi)]
  baa = p[p[p[noise.inc(xi)] + yi] + zi ]
  bba = p[p[p[noise.inc(xi) + noise.inc(yi)] + zi]]
  bab = p[p[p[noise.inc(xi)] + yi] + noise.inc(zi)]
  bbb = p[p[p[noise.inc(xi)] + noise.inc(yi)] + noise.inc(zi)]

  var
    x1 = lerp(grad(aaa, fracPos.x, fracPos.y, fracPos.z),
              grad(baa, fracPos.x - 1, fracPos.y, fracPos.z), u)
    x2 = lerp(grad(aba, fracPos.x, fracPos.y - 1, fracPos.z),
              grad(bba, fracPos.x - 1, fracPos.y - 1, fracPos.z), u)
    y1 = lerp(x1, x2, v)
    y2: float64
    
  x1 = lerp(grad(aab, fracPos.x, fracPos.y, fracPos.z - 1),
            grad(bab, fracPos.x - 1, fracPos.y, fracPos.z - 1), u)
  x2 = lerp(grad(abb, fracPos.x, fracPos.y - 1, fracPos.z - 1),
            grad(bbb, fracPos.x - 1, fracPos.y - 1, fracPos.z - 1), u)
  y2 = lerp(x1, x2, v)

  result = (lerp(y1, y2, w) + 1) / 2