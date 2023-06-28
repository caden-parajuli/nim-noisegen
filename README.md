# Noisegen - Nim noise generation library

## About

Supported noise functions are in the following table. The `GPU` column marks whether the noise function can be used in a GPU shader (e.g. via [shady](https://github.com/treeform/shady)). Analytic gradients are significantly faster and more accurate to the actual geometry than regular gradients computed by a central difference quotient. Analytic gradients can be used to easily compute surface normals since $\mathbf{n} = \pm\left( \frac{\partial f}{\partial x}(\mathbf{v}), \frac{\partial f}{\partial y}(\mathbf{v}), -1 \right)$ is a normal vector to the surface given by $z = f(x, y)$.

| Noise        |  CPU |  GPU | Gradient | Analytic Gradient |
|--------------|------|------|----------|-------------------|
| Perlin       | ✅︎   | ❌   | ❌       |  ❌              |
| Value        | ❌   | ❌   | ❌       |  ❌              |
| Voronoise    | ❌   | ❌   | ❌       |  ❌              |
| OpenSimplex  | ❌   | ❌   | ❌       |  ❌              |
| OpenSimplex2 | ❌   | ❌   | ❌       |  ❌              |

## Implementation Details

The Perlin noise function is a translation of Ken Perlin's ["Improved Noise reference implementation"](https://mrl.cs.nyu.edu/~perlin/noise) from Java to Nim. 
