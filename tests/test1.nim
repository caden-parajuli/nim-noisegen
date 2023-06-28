# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import noisegen/[perlin, base]


test "Perlin":
  var
    perlin = newPerlin(repeat = 0)    
  echo perlin.noise(dvec3(12.0, 14.0, 129.41768))
  
