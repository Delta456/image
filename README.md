# image

A port of Go's stdlib/image to V. It is highly Work in Progress.

## TODO List

- [x] `image/color/color.v`
- [x] `image/color/ycbcr.v`
- [x] `image/geom.v`
- [ ] `image/geom_test.v` (~20% done, tests are failing for some reason)
- [ ] `image/color/ycbcr_test.v` (~30% done)
- [ ] `image/color/color_test.v` (not started)
- [x] `image/name.v`
- [ ] `image/image.v` (not started in lieu of insufficient progress in `image/image.v`)
- [ ] `image/ycbcr.v` (~40% done)
- [ ] `image/image.v` (~10% done)
- [ ] `image/jpeg/` (not started, waiting for `io` and `bufio` modules)
- [ ] `image/png/` (not started, waiting for `io` and `bufio` modules)
- [ ] `image/gif/` (not started, waiting for `io` and `bufio` modules)
- [ ] `image/format.v` (not started)
- [ ] `image/draw` (not started, waiting for `io` and `bufio` modules)
- [ ] `image/internal` (not started)

## Acknowledgements

I thank the authors of `stdlib/image` for making their code public plus adding comments where explanation was needed.
