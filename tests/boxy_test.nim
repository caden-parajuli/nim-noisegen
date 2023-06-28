# To run these tests, simply execute `nimble test`.

import noisegen/perlin
import vmath, chroma, boxy, opengl, windy

let window = newWindow("Windy + Boxy", ivec2(1080, 1080))
makeContextCurrent(window)
loadExtensions()

let bxy = newBoxy()

var frame: int = 1

window.onFrame = proc() =
  # Clear the screen and begin a new frame.
  bxy.beginFrame(window.size)

  # Draw the bg.
  bxy.drawRect(rect(vec2(0, 0), window.size.vec2), color(0, 0, 0, 1))

  bxy.saveTransform()

  var
    pearl: uint8
    z: float64
  
  let
    w = 1080
    id = $(frame mod 30)
    image = newImage(1080, 1080)
  z = 4.0'f64 * ((frame mod 30).float64 / 30.0'f64)
  for y in 0 ..< image.height:
    for x in 0 ..< image.width:
      pearl = (0xff and floor(256 * (perlinOctaves(x.float64 / (1080.0'f64 / 32.0'f64), y.float64 / (1080.0'f64 / 32.0'f64), z, octaves = 1, persistence = 0.5'f64)) / 2 + 0.5).uint8)
      image[x, y] = rgba(pearl, pearl, pearl, 255)

  bxy.addImage("Perlin" & id, image)
  bxy.drawImage("Perlin" & id, center = window.size.vec2 / 2, angle = 0)

  bxy.restoreTransform()
  # End this frame, flushing the draw commands.
  bxy.endFrame()
  # Swap buffers displaying the new Boxy frame.
  window.swapBuffers()
  inc frame

while not window.closeRequested:
  pollEvents()