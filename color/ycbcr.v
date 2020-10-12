module color

pub fn ycbcr_to_rgb(y, cb, cr byte) (byte, byte, byte, byte) {
	yy1 := int(y) * 0x10101
	cb1 := int(cb) - 128
	cr1 := int(cr) - 128

	mut r := yy1 + 91881*cr1
	if u32(r) & 0xff_000_000 == 0 {
		r >>= 16
	} else {
		r = ^(r >> 31)
	}

	mut g := yy1 - 22554*cb1 - 46802*cr1
	if u32(g) & 0xff_000_000 == 0 {
		g >>= 16
	} else {
		g = ^(g >> 31)
	}

	mut b := yy1 + 116130*cb1
	if u32(b) & 0xff_000_000 == 0 {
		b >>= 16
	} else {
		b = ^(b >> 31)
	}

	return byte(r), byte(g), byte(b
}

pub fn rgb_to_ycbcr(r, g, b byte) (byte, byte, byte, byte) {
	r1 := int(r)
	g1 := int(g)
	b1 := int(b)

	yy := (19595*r1 + 38470*g1 + 7471*b1 + 1<<15) >> 16

	
	mut cb := -11056*r1 - 21712*g1 + 32768*b1 + 257<<15
	if u32(cb) & 0xff_000_000 == 0 {
		cb >>= 16
	} else {
		cb = ^(cb >> 31)
	}

	
	mut cr := 32768*r1 - 27440*g1 - 5328*b1 + 257<<15
	if u32(cr) & 0xff_000_000 == 0 {
		cr >>= 16
	} else {
		cr = ^(cr >> 31)
	}

	return byte(yy), byte(cb), byte(cr)
}

pub struct YCbCr {
pub:
	y byte
	cb byte
	cr byte
}
pub fn (c YCbCr) rgba() (u32, u32, u32, u32) {
	yy1 := int(c.y) * 0x10101
	cb1 := int(c.cb) - 128
	cr1 := int(c.cr) - 128

	mut r := yy1 + 91881*cr1
	if u32(r) & 0xff_000_000 == 0 {
		r >>= 8
	} else {
		r = ^(r >> 31) & 0xffff
	}

	mut g := yy1 - 22554*cb1 - 46802*cr1
	if u32(g) & 0xff_000_000 == 0 {
		g >>= 8
	} else {
		g = ^(g >> 31) & 0xffff
	}

	mut b := yy1 + 116130*cb1
	if u32(b) &0xff_000_000 == 0 {
		b >>= 8
	} else {
		b = ^(b >> 31) & 0xffff
	}

	return u32(r), u32(g), u32(b), 0xffff
}

pub fn new_ycbcr_model() Model {
	return model_fn(ycbcr_model)
}

fn ycbcr_model(c Color) Color {
	if c is YCbCr {
		return c
	}
	r, g, b, _ := c.rbga()
	y, u, v := rbg_to_ycbcr(byte(r>>8), byte(g>>8), byte(b>>8))
	return YCbCr{y, u, v}
}

pub struct NyCbCr {
pub:
	y YCbCr
	a byte
}

fn (c YCbCr) rgba() (u32, u32, u32, u32) {
	// This code is a copy of the YCbCrToRGB fntion above, except that it
	// returns values in the range [0, 0xffff] instead of [0, 0xff]. There is a
	// subtle difference between doing this and having YCbCr satisfy the Color
	// interface by first converting to an rgba. The latter loses some
	// information by going to and from 8 bits per channel.
	//
	// For example, this code:
	//	const y, cb, cr = 0x7f, 0x7f, 0x7f
	//	r, g, b := color.YCbCrToRGB(y, cb, cr)
	//	r0, g0, b0, _ := color.YCbCr{y, cb, cr}.rgba()
	//	r1, g1, b1, _ := color.rgba{r, g, b, 0xff}.rgba()
	//	fmt.Printf("0x%04x 0x%04x 0x%04x\n", r0, g0, b0)
	//	fmt.Printf("0x%04x 0x%04x 0x%04x\n", r1, g1, b1)
	// prints:
	//	0x7e18 0x808d 0x7db9
	//	0x7e7e 0x8080 0x7d7d

	yy1 := int(c.Y) * 0x10101
	cb1 := int(c.Cb) - 128
	cr1 := int(c.Cr) - 128

	// The bit twiddling below is equivalent to
	//
	// r := (yy1 + 91881*cr1) >> 8
	// if r < 0 {
	//     r = 0
	// } else if r > 0xff {
	//     r = 0xffff
	// }
	//
	// but uses fewer branches and is faster.
	// The code below to compute g and b uses a similar pattern.
	r := yy1 + 91881*cr1
	if u32(r)&0xff000000 == 0 {
		r >>= 8
	} else {
		r = ^(r >> 31) & 0xffff
	}

	g := yy1 - 22554*cb1 - 46802*cr1
	if u32(g)&0xff000000 == 0 {
		g >>= 8
	} else {
		g = ^(g >> 31) & 0xffff
	}

	b := yy1 + 116130*cb1
	if u32(b)&0xff000000 == 0 {
		b >>= 8
	} else {
		b = ^(b >> 31) & 0xffff
	}

	return u32(r), u32(g), u32(b), 0xffff
}

// YCbCrModel is the Model for Y'CbCr colors.
pub fn new_ycbcr_model() Model {
	return model_fn(ycbcr_model)
}

fn ycbcr_model(c Color) Color {
	if c is YCbCr {
		return c
	}
	r, g, b, _ := c.rgba()
	y, u, v := rgb_To_ycbcr(byte(r>>8), byte(g>>8), byte(b>>8))
	return YCbCr{y, u, v}
}

// NYCbCrA represents a non-alpha-premultiplied Y'CbCr-with-alpha color, having
// 8 bits each for one luma, two chroma and one alpha component.
struct NYCbCrA {
pub:
	y YCbCr
	A byte
}

fn (c NYCbCrA) rgba() (u32, u32, u32, u32) {
	// The first part of this method is the same as YCbCr.rgba.
	yy1 := int(c.y.y) * 0x10101
	cb1 := int(c.y.cb) - 128
	cr1 := int(c.y.cr) - 128

	// The bit twiddling below is equivalent to
	//
	// r := (yy1 + 91881*cr1) >> 8
	// if r < 0 {
	//     r = 0
	// } else if r > 0xff {
	//     r = 0xffff
	// }
	//
	// but uses fewer branches and is faster.
	// The code below to compute g and b uses a similar pattern.
	mut r := yy1 + 91881*cr1
	if u32(r)&0xff000000 == 0 {
		r >>= 8
	} else {
		r = ^(r >> 31) & 0xffff
	}

	mut g := yy1 - 22554*cb1 - 46802*cr1
	if u32(g)&0xff000000 == 0 {
		g >>= 8
	} else {
		g = ^(g >> 31) & 0xffff
	}

	mut b := yy1 + 116130*cb1
	if u32(b)&0xff000000 == 0 {
		b >>= 8
	} else {
		b = ^(b >> 31) & 0xffff
	}

	// The second part of this method applies the alpha.
	a := u32(c.A) * 0x101
	return u32(r) * a / 0xffff, u32(g) * a / 0xffff, u32(b) * a / 0xffff, a
}

// NYCbCrAModel is the Model for non-alpha-premultiplied Y'CbCr-with-alpha
// colors.
/*var NYCbCrAModel Model = ModelFunc(nYCbCrAModel)

fn nYCbCrAModel(c Color) Color {
	switch c := c.(type) {
	case NYCbCrA:
		return c
	case YCbCr:
		return NYCbCrA{c, 0xff}
	}
	r, g, b, a := c.rgba()

	// Convert from alpha-premultiplied to non-alpha-premultiplied.
	if a != 0 {
		r = (r * 0xffff) / a
		g = (g * 0xffff) / a
		b = (b * 0xffff) / a
	}

	y, u, v := RGBToYCbCr(byte(r>>8), byte(g>>8), byte(b>>8))
	return NYCbCrA{YCbCr{Y: y, Cb: u, Cr: v}, byte(a >> 8)}
}
*/
// rgb_to_cmyk converts an RGB triple to a CMYK quadruple.
pub fn rgb_to_cmyk(r, g, b byte) (byte, byte, byte, byte) {
	rr := u32(r)
	gg := u32(g)
	bb := u32(b)
	mut w := rr
	if w < gg {
		w = gg
	}
	if w < bb {
		w = bb
	}
	if w == 0 {
		return 0, 0, 0, 0xff
	}
	c := (w - rr) * 0xff / w
	m := (w - gg) * 0xff / w
	y := (w - bb) * 0xff / w
	return byte(c), byte(m), byte(y), byte(0xff - w)
}

// cmyk_to_rgb converts a CMYK quadruple to an RGB triple.
fn cmyk_to_rgb(c, m, y, k byte) (byte, byte, byte) {
	w := 0xffff - u32(k)*0x101
	r := (0xffff - u32(c)*0x101) * w / 0xffff
	g := (0xffff - u32(m)*0x101) * w / 0xffff
	b := (0xffff - u32(y)*0x101) * w / 0xffff
	return byte(r >> 8), byte(g >> 8), byte(b >> 8)
}

// CMYK represents a fully opaque CMYK color, having 8 bits for each of cyan,
// magenta, yellow and black.
//
// It is not associated with any particular color profile.
struct Cmyk {
pub:
	c byte
	m byte
	y byte
	k byte
}

pub fn (c Cmyk) rgba() (u32, u32, u32, u32) {
	// This code is a copy of the cmyk_to_rgb fntion above, except that it
	// returns values in the range [0, 0xffff] instead of [0, 0xff].

	w := 0xffff - u32(c.K)*0x101
	r := (0xffff - u32(c.C)*0x101) * w / 0xffff
	g := (0xffff - u32(c.M)*0x101) * w / 0xffff
	b := (0xffff - u32(c.Y)*0x101) * w / 0xffff
	return r, g, b, 0xffff
}

// CMYKModel is the Model for CMYK colors.
pub fn new_cmyk_model() Model {
	return model_fn(cmyk_model)
} 

fn cmyk_model(c Color) Color {
	if c is Cmyk {
		return c
	}
	r, g, b, _ := c.rgba()
	cc, mm, yy, kk := rgb_to_cymk(byte(r>>8), byte(g>>8), byte(b>>8))
	return CMYK{cc, mm, yy, kk}
}
