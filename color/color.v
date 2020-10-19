module color

// Color can convert itself to alpha-premultiplied 16-bits per channel RGBA.
// The conversion may be lossy.
pub interface Color {
	// RGBA returns the alpha-premultiplied red, green, blue and alpha values
	// for the color. Each value ranges within [0, 0xffff], but is represented
	// by a uint32 so that multiplying by a blend factor up to 0xffff will not
	// overflow.
	//
	// An alpha-premultiplied color component c has been scaled by alpha (a),
	// so has valid values 0 <= c <= a.
	rgba() (u32, u32, u32, u32)
}

// RGBA represents a traditional 32-bit alpha-premultiplied color, having 8
// bits for each of red, green, blue and alpha.
//
// An alpha-premultiplied color component C has been scaled by alpha (A), so
// has valid values 0 <= C <= A.
pub struct RGBA {
pub:
	r byte
	g byte
	b byte
	a byte
}

pub fn (rb RGBA) rgba() (u32, u32, u32, u32) {
	mut r := u32(rb.r)
	r |= r << 8

	mut b := u32(rb.b)
	b |= b << 8

	mut g := u32(rb.g)
	g |= g << 8

	mut a := u32(rb.a)
	a |= a << 8

	return r, b, g, a
}

// RGBA64 represents a 64-bit alpha-premultiplied color, having 16 bits for
// each of red, green, blue and alpha.
//
// An alpha-premultiplied color component C has been scaled by alpha (A), so
// has valid values 0 <= C <= A.
pub struct RGBA64 {
pub:
	r u16
	g u16
	b u16
	a u16
}

pub fn (c RGBA64) rgba() (u32, u32, u32, u32) {
	return u32(c.r), u32(c.g), u32(c.b), u32(c.a)
}

// NRGBA represents a non-alpha-premultiplied 32-bit color.
pub struct NRGBA {
pub:
	r byte
	g byte
	b byte
	a byte
}

pub fn (c NRGBA) rgba() (u32, u32, u32, u32) {
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

// NRGBA64 represents a non-alpha-premultiplied 64-bit color,
// having 16 bits for each of red, green, blue and alpha.
pub struct NRGBA64 {
pub:
	r u16
	g u16
	b u16
	a u16
}

pub fn (c NRGBA64) rgba() (u32, u32, u32, u32) {
	mut r := u32(c.r)
	r *= u32(c.a)
	r /= 0xffff

	mut g := u32(c.g)
	g *= u32(c.a)
	g /= 0xffff

	mut b := u32(c.b)
	b *= u32(c.a)
	b /= 0xffff

	a := u32(c.a)
	return r, g, b, a
}

// Alpha represents an 8-bit alpha color
pub struct Alpha {
pub:
	a byte
}

pub fn (al Alpha) rgba() (u32, u32, u32, u32) {
	mut a := u32(al.a)
	a |= a << 8
	return a, a, a, a
}

pub struct Alpha16 {
pub:
	a u16
}

// Alpha16 represents a 16-bit alpha color
pub fn (al Alpha16) rgba() (u32, u32, u32, u32) {
	a := u32(al.a)
	return a, a, a, a
}

// Gray represents an 8-bit grayscale color.
pub struct Gray {
pub:
	y byte
}

pub fn (g Gray) rgba() (u32, u32, u32, u32) {
	mut y := u32(g.y)
	y |= y << 8
	return y, y, y, 0xffff
}

// Gray16 represents an 16-bit grayscale color.
pub struct Gray16 {
pub:
	y u16
}

pub fn (g Gray16) rgba() (u32, u32, u32, u32) {
	y := u32(g.y)
	return y, y, y, 0xffff
}

pub interface Model {
	convert(c Color) Color
}

fn model_fn(f fn (Color) Color) Model {
	return ModelFn{f}
}

struct ModelFn {
	f fn (Color) Color
}

fn (m &ModelFn) convert(c Color) Color {
	return m.f(c)
}

pub fn new_rgba_model() Model {
	return model_fn(rgba_model)
}

pub fn new_rgba64_model() Model {
	return model_fn(rgba64_model)
}

pub fn new_nrgba_model() Model {
	return model_fn(nrgba_model)
}

pub fn new_nrgba64_model() Model {
	return model_fn(nrgba64_model)
}

pub fn new_alpha_model() Model {
	return model_fn(alpha_model)
}

pub fn new_alpha16_model() Model {
	return model_fn(alpha16_model)
}

pub fn new_gray_model() Model {
	return model_fn(gray_model)
}

pub fn new_gray16_model() Model {
	return model_fn(gray16_model)
}

fn rgba_model(c Color) Color {
	if c is RGBA {
		return c
	}
	r, g, b, a := c.rgba()
	return RGBA{byte(r >> 8), byte(g >> 8), byte(b >> 8), byte(a >> 8)}
}

fn rgba64_model(c Color) Color {
	if c is RGBA64 {
		return c
	}
	r, g, b, a := c.rgba()
	return RGBA64{u16(r), u16(g), u16(b), u16(a)}
}

fn nrgba_model(c Color) Color {
	if c is NRGBA {
		return c
	}
	mut r, mut g, mut b, mut a := c.rgba()
	if a == 0xffff {
		return NRGBA{byte(r >> 8), byte(g >> 8), byte(b >> 8), 0xff}
	}
	if a == 0 {
		return NRGBA{0, 0, 0, 0}
	}
	// Since Color.rgba returns an alpha-premultiplied color, we should have r <= a && g <= a && b <= a.
	r = (r * 0xffff) / a
	g = (g * 0xffff) / a
	b = (b * 0xffff) / a
	return NRGBA{byte(r >> 8), byte(g >> 8), byte(b >> 8), byte(a >> 8)}
}

fn nrgba64_model(c Color) Color {
	if c is NRGBA64 {
		return c
	}
	mut r, mut g, mut b, mut a := c.rgba()
	if a == 0xffff {
		return NRGBA64{u16(r), u16(g), u16(b), 0xffff}
	}
	if a == 0 {
		return NRGBA64{0, 0, 0, 0}
	}
	// Since Color.rgba returns an alpha-premultiplied color, we should have r <= a && g <= a && b <= a.
	r = (r * 0xffff) / a
	g = (g * 0xffff) / a
	b = (b * 0xffff) / a
	return NRGBA64{u16(r), u16(g), u16(b), u16(a)}
}

fn alpha_model(c Color) Color {
	if c is Alpha {
		return c
	}
	_, _, _, a := c.rgba()
	return Alpha{byte(a >> 8)}
}

fn alpha16_model(c Color) Color {
	if c is Alpha16 {
		return c
	}
	_, _, _, a := c.rgba()
	return Alpha16{u16(a)}
}

fn gray_model(c Color) Color {
	if c is Gray {
		return c
	}
	r, g, b, _ := c.rgba()

	// These coefficients (the fractions 0.299, 0.587 and 0.114) are the same
	// as those given by the JFIF specification and used by fn RGBToYCbCr in
	// ycbcr.v.
	//
	// Note that 19595 + 38470 + 7471 equals 65536.
	//
	// The 24 is 16 + 8. The 16 is the same as used in RGBToYCbCr. The 8 is
	// because the return value is 8 bit color, not 16 bit color.
	y := (19595 * r + 38470 * g + 7471 * b + 1 << 15) >> 24
	return Gray{byte(y)}
}

fn gray16_model(c Color) Color {
	if c is Gray16 {
		return c
	}
	r, g, b, _ := c.rgba()

	// These coefficients (the fractions 0.299, 0.587 and 0.114) are the same
	// as those given by the JFIF specification and used by fn RGBToYCbCr in
	// ycbcr.v.
	//
	// Note that 19595 + 38470 + 7471 equals 65536.
	y := (19595 * r + 38470 * g + 7471 * b + 1 << 15) >> 16
	return Gray16{u16(y)}
}

pub const (
	black       = Gray16{0}
	white       = Gray16{0xffffff}
	transparent = Alpha16{0}
	opaque      = Alpha16{0xffffff}
)
