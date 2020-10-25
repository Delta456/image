import color

fn delta(x byte, y byte) byte {
	if x >= y {
		return x - y
	}
	return y - x
}

fn eq(c1 color.Color, c2 color.Color) bool {
	r0, g0, b0, a0 := c1.rgba()
	r1, g1, b1, a1 := c2.rgba()
	if r0 != r1 || g0 != g1 || b0 != b1 || a0 != a1 {
		return false
	}
	return true
}
/* TODO: figure out why it is not passing
fn test_ycbcr_round_trip() {
	for r := 0; r < 256; r += 7 {
		for g := 0; g < 256; g += 5 {
			for b := 0; b < 256; b += 3 {
				r0, g0, b0 := byte(r), byte(g), byte(b)
				y, cb, cr := color.rgb_to_ycbcr(r0, g0, b0)
				r1, g1, b1 := color.ycbcr_to_rgb(y, cb, cr)
				if delta(r0, r1) > 2 || delta(g0, g1) > 2 || delta(b0, b1) > 2 {
					eprintln('\nr0, g0, b0 = $r0, $g0, $b0\ny, cb, cr = $y, $cb, $cr\nr1, g1, b1 = $r1, $g1, $b1')
					assert false
				}
			}
		}
	}
	assert true
}
*/

// test_ycbcr_to_rgb_consistency tests that calling the color.RGBA method (16 bit color)
// then truncating to 8 bits is equivalent to calling the ycbcr_to_rgb function (8
// bit color).
fn test_ycbcr_to_rgb_consistency() {
	for y := 0; y < 256; y += 7 {
		for cb := 0; cb < 256; cb += 5 {
			for cr := 0; cr < 256; cr += 3 {
				x := color.YCbCr{byte(y), byte(cb), byte(cr)}
				r0, g0, b0, _ := x.rgba()
				r1, g1, b1 := byte(r0>>8), byte(g0>>8), byte(b0>>8)
				r2, g2, b2 := color.ycbcr_to_rgb(x.y, x.cb, x.cr)
				if r1 != r2 || g1 != g2 || b1 != b2 {
					eprintln('\nr0, g0, b0 = $r0, $g0, $b0\nr1, g1, b1 = $r1, $g1, $b1\nr2, g2, b2 = $r2, $g2, $b2')
					assert false
				}
			}
		}
	}
	assert true
}

// test_ycbcr_gray tests that YCbCr colors are a superset of Gray colors.
fn test_ycbcr_gray() {
	for i := 0; i < 256; i++ {
		c0 := color.YCbCr{byte(i), 0x80, 0x80}
		c1 := color.Gray{byte(i)}	
		if !eq(c0, c1) {
			eprintln('$c0 and $c1 are not equal')
			assert false
		}
	}
	assert true
}

// test_nycbcra_alpha tests that NYCbCrA colors are a superset of Alpha colors.
fn test_nycbcr_alpha() {
	for i := 0; i < 256; i++ {
		c0 := color.NYCbCrA{color.YCbCr{byte(i), 0x40, 0xc0}, 0xff}
		c1 := color.YCbCr{byte(i), 0x40, 0xc0}
		if !eq(c0, c1) {
			eprintln('$c0 and $c1 are not equal')
			assert false
		}
	}
	assert true
}

// test_cmyk_to_rgb_consistency tests that calling the color.RGBA method (16 bit color)
// then truncating to 8 bits is equivalent to calling the ycbcr_to_rgb function (8
// bit color).
fn test_cmyk_to_rgb_consistency() {
	for c := 0; c < 256; c += 7 {
		for m := 0; m < 256; m += 5 {
			for y := 0; y < 256; y += 3 {
				for k := 0; k < 256; k += 11 {
				x := color.CMYK{byte(c), byte(m), byte(y), byte(k)}
				r0, g0, b0, _ := x.rgba()
				r1, g1, b1 := byte(r0>>8), byte(g0>>8), byte(b0>>8)
				r2, g2, b2 := color.cmyk_to_rgb(x.c, x.m, x.y, x.k)
				if r1 != r2 || g1 != g2 || b1 != b2 {
					eprintln('\nr0, g0, b0 = $r0, $g0, $b0\nr1, g1, b1 = $r1, $g1, $b1\nr2, g2, b2 = $r2, $g2, $b2')
					assert false
				}
			   }
			}
		}
	}
	assert true
}


// test_cmyk_gray tests that CMYK colors are a superset of Gray colors.
fn test_cmyk_gray() {
	for i := 0; i < 256; i++ {
		c := color.CMYK{0x00, 0x00, 0x00, byte(255 - i)}
		g := color.Gray{byte(i)}
		//TODO: uncomment when this will work
		//if !eq(color.CMYK{0x00, 0x00, 0x00, byte(255 - i)}, color.Gray{byte(i)}) {}
		if !eq(c, g) {
			eprintln('i=${i:0x2}')
			assert false
		}
	}
	assert true
}
/* TODO: enable this test when I can think of the most suitable way
fn test_palette() {
	p := color.Palette{
		colors: [color.RGBA{0xff, 0xff, 0xff, 0xff},
		color.RGBA{0x80, 0x00, 0x00, 0xff},
		color.RGBA{0x7f, 0x00, 0x00, 0x7f},
		color.RGBA{0x00, 0x00, 0x00, 0x7f},
		color.RGBA{0x00, 0x00, 0x00, 0x00},
		color.RGBA{0x40, 0x40, 0x40, 0x40}]
	}
	// Check that, for a Palette with no repeated colors, the closest color to
	// each element is itself.
	for i, c in p.colors {
		j := p.index(c)
		if i != j {
			//eprintln('got $j color = ${p.index(j)}, want $i')
			assert false
			//t.Errorf("Index(%v): got %d (color = %v), want %d", c, j, p[j], i)
		}
	}
	// Check that finding the closest color considers alpha, not just red,
	// green and blue.
	/*got := p.convert(color.RGBA{0x80, 0x00, 0x00, 0x80}) or { none }
	want := color.RGBA{0x7f, 0x00, 0x00, 0x7f}
	if got != want {
		//eprintln('got=$got, want=$want')
		assert false
	}*/
	assert true
}
*/
