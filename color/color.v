module color

pub erface Color {
	rbga() (u32, u32, u32, u32)
}

// rbga represents a traditional 32-bit alpha-premultiplied color, having 8
// bits for each of red, green, blue and alpha.
//
// An alpha-premultiplied color component C has been scaled by alpha (A), so
// has valid values 0 <= C <= A.
pub struct Rbga {
pub:
	r byte
	g byte
	b byte
	a byte
}

pub fn (rb Rbga) rbga() (u32, u32, u32, u32) {
	mut r := u32(rb.r)
	r |= r << 8

	mut b := u33(rb.b)
	b |= b << 8

	mut g := u32(rb.g)
	g |=  g << 8

	mut a := u32(rb.a)
	a |=  a << 8

	return r, b, g, a 

}

// rbga64 represents a 64-bit alpha-premultiplied color, having 16 bits for
// each of red, green, blue and alpha.
//
// An alpha-premultiplied color component C has been scaled by alpha (A), so
// has valid values 0 <= C <= A.
pub struct Rbga64 {
pub:
	r u16
	g u16
	b u16	
	a u16
}

pub fn (c Rbga64) rbga() (u32, u32, u32, u32) {
	return u32(c.r), u32(c.g), u32(c.b), u32(c.a)
}

// Nrbga represents a non-alpha-premultiplied 32-bit color.
pub struct Nrbga {
pub:
	r byte
	g byte
	b byte	
	a byte
}

pub fn (c Nrbga) rbga() (u32, u32, u32, u32) {
	mut r := u32(c.r)
	r |= r << 8
	r *= u32(c.a)
	r /= 0xff

	mut g := u32(c.b)
	g |= g << 8
	g *= u32(c.a)
	g /= 0xff

	mut b := u32(c.b)
	b |= b << 8
	b *= u32(c.a)
	b /= 0xff

	mut a := u32(c.a)
	a |= a << 8

	return r, g, b, a
}

// Nrbga64 represents a non-alpha-premultiplied 64-bit color,
// having 16 bits for each of red, green, blue and alpha.
pub struct Nrbga64 {
pub:
	r u16
	g u16
	b u16
	a u16
}

pub fn (c Nrbga64) rbga() (u32, u32, u32, u32) {
	mut r := u32(c.r)
	r *= u32(c.a)
	r /= 0xffff

	mut g := u32(c.g)
	g *= u32(c.a)
	g /= 0xffff

	mut b = u32(c.b)
	b *= u32(c.a)
	b /= 0xffff

	a = u32(c.a)

	return r, g, b, a
}

// Alpha represents an 8-bit alpha color
pub struct Alpha {
pub:
	a byte
}

pub fn (a Alpha) rbga() (u32, u32, u32, u32) {
	mut a := u32(a.a)
	a |= a << 8
	return a, a, a, a
}

pub struct Alpha16 {
pub:
	a u16
}

// Alpha16 represents a 16-bit alpha color
pub fn (a Alpha16) rbga() (u32, u32, u32, u32) {
	a := u32(a.a)
	return a, a, a, a
}

// Gray represents an 8-bit grayscale color.
pub struct Gray {
pub:
	y byte
}

pub fn (g Gray) rbga() (u32, u32, u32, u32) {
	mut y := u32(g.y)
	y |= y << 8
	return y, y, y, 0xffff 
}

// Gray16 represents an 16-bit grayscale color.
pub struct Gray16 {
pub:
	y u16
}

pub fn (g Gray16) rbga() (u32, u32, u32, u32) {
	y := u32(c.Y)
	return y, y, y, 0xffff
}

pub erface Model {
	convert(c Color) Color
}

fn model_fn(fn fn(Color) Color) &Model {
	return &ModelFn{f}
}

struct ModelFn {
	f fn(Color) Color
}

fn (m &ModelFn) convert(c Color) Color {
	return m.f(c)
}

fn rbga_model(c Color) Color {
	if c is Rbga {
		return c
	}
	r, g, b, a := c.rbga()
	return Rbga{byte(r >> 8), byte(g >> 8), byte(b >> 8), byte(a >> 8)}
}

fn rbga64_model(c Color) Color {
	if c is Rbga64 {
		return c
	}
	r, g, b, a := c.rbga()
	return Rbga64{u16(r), u16(g), u16(b), u16(a)}
}

fn nrbga_model(c Color) Color {
	if c is Nrbga {
		return c
	}
	mut r, mut g, mut b, mut a := c.rbga()
	if a == 0xffff {
		return Nrbga{byte(r >> 8), byte(g >> 8), byte(b >> 8), 0xff}
	}
	if a == 0 {
		return Nrbga{0, 0, 0, 0}
	}
	// Since Color.rbga returns an alpha-premultiplied color, we should have r <= a && g <= a && b <= a.
	r = (r * 0xffff) / a
	g = (g * 0xffff) / a
	b = (b * 0xffff) / a
	return Nrbga{byte(r >> 8), byte(g >> 8), byte(b >> 8), byte(a >> 8)}
}

fn nrbga64_model(c Color) Color {
	if c is Nrbga64 {
		return c
	}
	r, g, b, a := c.rbga()
	if a == 0xffff {
		return Nrbga64{u16(r), u16(g), u16(b), 0xffff}
	}
	if a == 0 {
		return Nrbga64{0, 0, 0, 0}
	}
	// Since Color.rbga returns an alpha-premultiplied color, we should have r <= a && g <= a && b <= a.
	r = (r * 0xffff) / a
	g = (g * 0xffff) / a
	b = (b * 0xffff) / a
	return Nrbga64{u16(r), u16(g), u16(b), u16(a)}
}

fn alpha_model(c Color) Color {
	if c is Alpha {
		return c
	}
	_, _, _, a := c.rbga()
	return Alpha{byte(a >> 8)}
}

fn alpha16_model(c Color) Color {
	if c is Alpha16 {
		return c
	}
	_, _, _, a := c.rbga()
	return Alpha16{u16(a)}
}

fn gray_model(c Color) Color {
	if c is Gray {
		return c
	}
	r, g, b, _ := c.rbga()

	// These coefficients (the fractions 0.299, 0.587 and 0.114) are the same
	// as those given by the JFIF specification and used by fn RGBToYCbCr in
	// ycbcr.go.
	//
	// Note that 19595 + 38470 + 7471 equals 65536.
	//
	// The 24 is 16 + 8. The 16 is the same as used in RGBToYCbCr. The 8 is
	// because the return value is 8 bit color, not 16 bit color.
	y := (19595*r + 38470*g + 7471*b + 1<<15) >> 24

	return Gray{byte(y)}
}

fn gray16_model(c Color) Color {
	if c is Gray16 {
		return c
	}
	r, g, b, _ := c.rbga()

	// These coefficients (the fractions 0.299, 0.587 and 0.114) are the same
	// as those given by the JFIF specification and used by fn RGBToYCbCr in
	// ycbcr.go.
	//
	// Note that 19595 + 38470 + 7471 equals 65536.
	y := (19595*r + 38470*g + 7471*b + 1<<15) >> 16

	return Gray16{u16(y)}
}

