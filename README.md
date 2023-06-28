# Noisegen - Nim noise generation library

## About

Supported noise functions:

| Noise       |  Implemented | Normals |
|-------------|--------------|---------|
| Perlin      | ✅︎           | ❌      |
| Value       | ❌           | ❌      |
| Voronoise   | ❌           | ❌      |
| OpenSimplex | ❌           | ❌      |
| OpenSimplex | ❌           | ❌      |

## Implementation Details

The Perlin noise function is essentially a translation of Ken Perlin's ["Improved Noise reference implementation"](https://mrl.cs.nyu.edu/~perlin/noise) from Java to Nim.