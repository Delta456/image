# image

A port of Go's stdlib/image to V. It is Highly Work in Progress.

## TODO List

- [ ] `image/color/color.v` (~98% done)
  - [x] RGBA
  - [x] RGBA64
  - [x] NRGBA
  - [x] NRGBA64
  - [x] Alpha
  - [x] Alpha16
  - [x] Gray
  - [x] Gray16
  - [ ] Palette (need more to think on this to how to do it with current limitations)
- [ ] `image/color/ycbcr.v` (~98% done)
  - [x] YCbCr
  - [x] NYCbCr
  - [x] YCbCrA
  - [x] CMYK
  - [ ] NYCbCrA (need more to think on this to how to do it with current limitations)
- [x] `image/geom.v`
- [ ] `image/geom_test.v` (~20% done, tests are failing for some reason)
- [ ] `image/color/ycbcr_test.v` (~30% done, tests are failing for some reason)
- [x] `image/color/color_test.v`
- [x] `image/name.v`
- [ ] `image/image_test.v` (not started in lieu of insufficient progress in `image/image.v`)
- [ ] `image/ycbcr.v` (98% done)
  - [x] YCbCr
  - [ ] NYCbCrA (2% left to do)
- [ ] `image/image.v` (~15% done)
    - [x] RGBA
    - [x] RGBA64
    - [x] NRGBA
    - [ ] NRGBA64
    - [ ] Alpha
    - [ ] Alpha16
    - [ ] Gray
    - [ ] Gray16
    - [ ] CMYK
    - [ ] Paletted
- [ ] `image/jpeg/` (not started, waiting for `io` and `bufio` modules)
- [ ] `image/png/` (not started, waiting for `io` and `bufio` modules)
- [ ] `image/gif/` (not started, waiting for `io` and `bufio` modules)
- [ ] `image/format.v` (not started, waiting for `io`, `sync/atomic` and `bufio` modules)
- [ ] `image/draw` (not started, waiting for `io` and `bufio` modules)
- [ ] `image/internal/` (not started)

## Acknowledgements

I thank the authors of `stdlib/image` for making their code public plus adding comments where explanation was needed.
