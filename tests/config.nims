switch("path", "$projectDir/../src")

when defined(danger):
  --cc:gcc
  --gc:arc
  --opt:speed
  --checks:off
  --panics:on
  --passC:"-flto -march=native -O3 -m64"
  --passL:"-flto"
else:
  --cc:clang
