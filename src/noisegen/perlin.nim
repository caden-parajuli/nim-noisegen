import vmath
import base
import math

## Hash lookup table as defined by Ken Perlin
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
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,      # Repeats
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

proc grad(hash: int, x, y, z: float64): float64 =
  ## Returns dot product of the computed gradient vector with given x,y,z
  let
    h: int = hash and 15
    u = if h < 8: x else: y
    v = if h < 4: y else: (if ((h == 12) or (h == 14)): x else: z)    
  result = (if (h and 1) == 0: u else: -u) + (if (h and 2) == 0: v else: -v)

proc grads(hash: int, x, y, z: float64): (float64, IVec3) =
  ## Returns dot product of the computed gradient vector with given x,y,z, and the gradient itself
  case hash and 15:
        of 0: return  (x + y, ivec3(1, 1, 0))
        of 1: return (-x + y, ivec3(-1, 1, 0))
        of 2: return  (x - y, ivec3(1, -1, 0))
        of 3: return (-x - y, ivec3(-1, -1, 0))
        of 4: return  (x + z, ivec3(1, 0, 1))
        of 5: return (-x + z, ivec3(-1, 0, 1))
        of 6: return  (x - z, ivec3(1, 0, -1))
        of 7: return (-x - z, ivec3(-1, 0, -1))
        of 8: return  (y + z, ivec3(0, 1, 1))
        of 9: return (-y + z, ivec3(0, -1, 1))
        of 10: return  (y - z, ivec3(0, 1, -1))
        of 11: return (-y - z, ivec3(0, -1, -1))
        of 12: return  (x + y, ivec3(1, 1, 0))
        of 13: return (-y + z, ivec3(0, -1, 1))
        of 14: return (-x + y, ivec3(-1, 1, 0))
        of 15: return (-y - z, ivec3(0, -1, -1))
        else:
          # Should never happen
          assert(false)
          return (0.0, ivec3(0, 0, 0))
  
proc fade(t: float64): float64 {.inline.} =
  ## 6t^5 - 15t^4 + 10t^3
  return t * t * t * (t * (t * 6 - 15) + 10)

proc fade_dt(t: float64): float64 {.inline.} =
  ## $\frac{\partial \text{fade}}{\partial t} = 30(t^4 - 2t^3 + t^2)$
  return 30 * t * t * (t - 1) * (t - 1)
  
proc lerp(a, b, t: float64): float64 {.inline.} =
  ## Can replace with a call to `mix`
  return a + t * (b - a);

proc perlinNoise*(x, y, z: float64): float64 =
  ## Generates Perlin noise for point (x, y, z). To use for 2D noise, simply treat the z coordinate as a seed
  let
    xi = floor(x).int and 255
    yi = floor(y).int and 255
    zi = floor(z).int and 255
  var
    x = x - x.floor()
    y = y - y.floor()
    z = z - z.floor()
  let
    u = fade(x)
    v = fade(y)
    w = fade(z)
    a = p[xi] + yi
    aa = p[a] + zi
    ab = p[a + 1] + zi
    b = p[xi + 1] + yi
    ba = p[b] + zi
    bb = p[b + 1] + zi
  result = lerp(lerp(lerp(grad(p[aa],     x,    y,    z  ),
                          grad(p[ba],     x-1,  y,    z  ),
                          u),
                     lerp(grad(p[ab],     x,    y-1,  z  ),
                          grad(p[bb],     x-1,  y-1,  z  ),
                          u),
                     v),
                lerp(lerp(grad(p[aa + 1], x,    y,    z-1),
                          grad(p[ba + 1], x-1,  y,    z-1),
                          u),
                     lerp(grad(p[ab + 1], x,    y-1,  z-1),
                          grad(p[bb + 1], x-1,  y-1,  z-1),
                          u),
                     v),
                w)

proc perlinNoise*(pos: DVec3): float64 {.inline.} =
  return perlinNoise(pos.x, pos.y, pos.z)

proc perlinOctaves*(x, y, z: float64, octaves: int, persistence: float64): float64 =
  var
    total: float64 = 0
    frequency: float64 = 1
    amplitude: float64 = 1
    maxValue: float64 = 0  # Used for normalizing result to 0.0 - 1.0
  for i in 0 ..< octaves:
    total += perlinNoise(x * frequency, y * frequency, z * frequency) * amplitude;
    maxValue += amplitude;
    amplitude *= persistence;
    frequency *= 2;  
  return total / maxValue;

proc perlinOctaves*(pos: DVec3, octaves: int, persistence: float64 = 0.5): float64 {.inline.} =
  return perlinOctaves(pos.x, pos.y, pos.z, octaves, persistence)
  
proc perlinGradient*(x, y, z: float64): (float64, DVec3) =
  ##[
  Generates Perlin noise for point (x, y, z), and computes the analytic gradient (partial derivatives).
  To compute normals, use ±(grad.x, grad.y, -1)
  ]##
  let
    xi = floor(x).int and 255
    yi = floor(y).int and 255
    zi = floor(z).int and 255
  var
    x = x - x.floor()
    y = y - y.floor()
    z = z - z.floor()
  let
    u = fade(x)
    v = fade(y)
    w = fade(z)
    u_dx = fade_dt(x)
    v_dy = fade_dt(y)
    w_dz = fade_dt(y)
    a = p[xi] + yi
    aa = p[a] + zi
    ab = p[a + 1] + zi
    b = p[xi + 1] + yi
    ba = p[b] + zi
    bb = p[b + 1] + zi
    (dot000, g000) = grads(p[aa],     x,   y,   z  )
    (dot100, g100) = grads(p[ba],     x-1, y,   z  )
    (dot010, g010) = grads(p[ab],     x,   y-1, z  )
    (dot110, g110) = grads(p[bb],     x-1, y-1, z  )
    (dot001, g001) = grads(p[aa + 1], x  , y  , z-1)
    (dot101, g101) = grads(p[ba + 1], x-1, y  , z-1)
    (dot011, g011) = grads(p[ab + 1], x  , y-1, z-1)
    (dot111, g111) = grads(p[bb + 1], x-1, y-1, z-1)
  # Compute noise value
  result[0] = dot000 +
    u * (dot100 - dot000) +
    v * (dot010 - dot000) +
    w * (dot001 - dot000) +
    u * v * (dot110 - dot010 - dot100 + dot000) +
    u * w * (dot101 - dot001 - dot100 + dot000) +
    v * w * (dot011 - dot001 - dot010 + dot000) +
    u * v * w * (dot111 - dot011 - dot101 + dot001 - dot110 + dot010 + dot100 - dot000)
  # Ken Perlin's method, algebraically equivalent
  # result[0] = lerp(lerp(lerp(dot000, dot100, u),
  #                       lerp(dot010, dot110, u),
  #                       v),
  #                  lerp(lerp(dot001, dot101, u),
  #                       lerp(dot011, dot111, u),
  #                       v),
  #                  w)
  
  # Compute partial derivatives. Method from: https://stackoverflow.com/questions/4297024/3d-perlin-noise-analytical-derivative
  result[1].x = g000.x.float + u_dx * (dot100 - dot000) +
    u * (g100.x - g000.x).float +
    v * (g010.x - g000.x).float +
    w * (g001.x - g000.x).float +
    u_dx * v * (dot110 - dot010 - dot100 + dot000) +
    u * v * (g110.x - g010.x - g100.x + g000.x).float +
    u_dx * w * (dot101 - dot001 - dot100 + dot000) +
    u * w * (g101.x - g001.x - g100.x - g000.x).float +
    v * w * (g011.x - g001.x - g010.x + g000.x).float +
    u_dx * v * w * (dot111 - dot011 - dot101 + dot001 - dot110 + dot010 + dot100 - dot000) +
    u * v * w * (g111.x - g011.x - g101.x + g001.x - g110.x + g010.x + g100.x - g000.x).float
  result[1].y = g000.y.float + u * (g100.y - g000.y).float + 
    v_dy * (dot010 - dot000) +
    v * (g010.y - g000.y).float +
    w * (g001.y - g000.y).float +
    u * v_dy * (dot110 - dot010 - dot100 + dot000) +
    u * v * (g110.y - g010.y - g100.y + g000.y).float +
    u * w * (g101.y - g001.y - g100.y + g000.y).float +
    v_dy * w * (dot011 - dot001 - dot010 + dot000) +
    v * w * (g011.y - g001.y - g010.y + g000.y).float +
    u * v_dy * w * (dot111 - dot011 - dot101 + dot001 - dot110 + dot010 + dot100 - dot000) +
    u * v * w * (g111.y - g011.y - g101.y + g001.y - g110.y + g010.y + g100.y - g000.y).float
  result[1].z = g000.z.float +
    u * (g100.z - g000.z).float +
    v * (g010.z - g000.z).float +
    w_dz * (dot001 - dot000) +
    w * (g001.z - g000.z).float +
    u * v * (g110.z - g010.z - g100.z + g000.z).float +
    u * w_dz * (dot101 - dot001 - dot100 + dot000) +
    u * w * (g101.z - g001.z - g100.z + g000.z).float +
    v * w_dz * (dot011 - dot001 - dot010 + dot000) +
    v * w * (g011.z - g001.z - g010.z + g000.z).float +
    u * v * w_dz * (dot111 - dot011 - dot101 + dot001 - dot110 + dot010 + dot100 - dot000) +
    u * v * w * (g111.z - g011.z - g101.z + g001.z - g110.z + g010.z + g100.z - g000.z).float

    
proc perlinGradientOctaves*(x, y, z: float64, octaves: int, persistence: float64): (float64, DVec3) =
  var
    total: float64 = 0
    frequency: float64 = 1
    amplitude: float64 = 1
    maxValue: float64 = 0  # Used for normalizing result to -1.0 - 1.0
    noise: (float64, DVec3)
    totalNorm: DVec3
  for i in 0 ..< octaves:
    noise = perlinGradient(x * frequency, y * frequency, z * frequency)
    total += noise[0] * amplitude
    totalNorm += noise[1] * amplitude
    maxValue += amplitude
    amplitude *= persistence
    frequency *= 2
  return (total / maxValue, totalNorm / maxValue)

proc perlinGradientOctaves*(pos: DVec3, octaves: int, persistence: float64 = 0.5): (float64, DVec3) {.inline.} =
  return perlinGradientOctaves(pos.x, pos.y, pos.z, octaves, persistence)