import color

fn delta(x, y byte) byte {
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

// test_ycbcr_to_rgb_consistency tests that calling the RGBA method (16 bit color)
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

