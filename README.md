# Noisegen - Nim noise generation library

## About

Supported noise functions are in the following table. The `GPU` column marks whether the noise function can be used in a GPU shader (e.g. via [shady](https://github.com/treeform/shady)). Analytic gradients are significantly faster and more accurate to the actual geometry than regular gradients computed by a central difference quotient. Analytic gradients can be used to easily compute surface normals since $n = \left( \frac{\partial f}{\partial x}(v), \frac{\partial f}{\partial y}(v), -1 \right)$

| Noise        |  CPU |  GPU | Gradient | Analytic Gradient |
|--------------|------|------|----------|-------------------|
| Perlin       | ✅︎   | ❌   | ❌       |  ❌              |
| Value        | ❌   | ❌   | ❌       |  ❌              |
| Voronoise    | ❌   | ❌   | ❌       |  ❌              |
| OpenSimplex  | ❌   | ❌   | ❌       |  ❌              |
| OpenSimplex2 | ❌   | ❌   | ❌       |  ❌              |

## Implementation Details

The Perlin noise function is essentially a translation of Ken Perlin's ["Improved Noise reference implementation"](https://mrl.cs.nyu.edu/~perlin/noise) from Java to Nim.