module image

import image.color

// Config holds an image's color model and dimensions.
pub struct Config {
	color_model color.Model
	width int
	height int
}

// Image is a finite rectangular grid of color.Color values taken from a color
// model
pub interface Image {
	// color_model returns the Image's color model.
	color_model() color.Model
	// bounds returns the domain for which At can return non-zero color.
	// The bounds do not necessarily contain the point (0, 0).
	bounds() Rectangle
	// at returns the color of the pixel at (x, y).
	// at(Bounds().Min.X, Bounds().Min.Y) returns the upper-left pixel of the grid.
	// at(Bounds().Max.X-1, Bounds().Max.Y-1) returns the lower-right one.
	at(x int, y int) color.Color
}

// PalettedImage is an image whose colors may come from a limited palette.
// If m is a PalettedImage and m.color_model() returns a color.Palette p,
// then m.At(x, y) should be equivalent to p[m.color_index_at(x, y)]. If m's
// color model is not a color.Palette, then color_index_at's behavior is
// undefined.
pub interface PalettedImage {
	// color_index_at returns the palette index of the pixel at (x, y).
	color_index_at(x int, y int) byte
	color_model() color.Model // TODO: replace the below fns declaration with Image when
	bounds() Rectangle 	// interface embedding is done
	at(x int, y int) color.Color
}

pub struct RGBA {
	// pix holds the image's pixels, in R, G, B, A order. The pixel at
	// (x, y) starts at pix[(y-rect.min.y)*stride + (x-rect.min.x)*4].
	pix []byte
	// stride is the `pix` stride (in bytes) between vertically adjacent pixels.
	stride int
	// rect is the image's bound.
	rect Rectangle
}

pub fn (r RGBA) color_model() color.Model {
	return color.new_rgba_model()
}

pub fn (r RGBA) bounds() Rectangle {
	return r.rect
}

pub fn (r RGBA) at(x int, y int) color.Color {
	res := r.rgba_at(x, y) //temporary workaround for now
	return res 
}

pub fn (r RGBA) rgba_at(x int, y int) color.RGBA {
	p := Point{x, y}
	if !p.inside(r.rect) {
		return color.RGBA{}
	}
	i := r.pix_offset(x, y)
	s := r.pix[i..i+4]
	return color.RGBA{s[0], s[1], s[2], s[3]}
}


// pix_offset returns the index of the first element of `pix` that corresponds to
// the pixel at (x, y).
pub fn (p RGBA) pix_offset(x int, y int) int {
	return (y-p.rect.min.y)*p.stride + (x-p.rect.min.x)*4
}

/* TODO
fn (p RGBA) set(xint , y int, c color.Color) {
	if !(Point{x, y}.inside(p.Rect)) {
		return
	}
	i := p.pix_offset(x, y)
	c1 := color.RGBAModel.Convert(c).(color.RGBA)
	s := p.Pix[i : i+4 : i+4] // Small cap improves performance, see https://golang.org/issue/27857
	s[0] = c1.R
	s[1] = c1.G
	s[2] = c1.B
	s[3] = c1.A
}
*/
pub fn (r RGBA) set_rgba(x int, y int, c color.RGBA) {
	p := Point{x, y}
	if !p.inside(r.rect) {
		return
	}
	i := r.pix_offset(x, y)
	mut s := r.pix[i..i+4]
	s[0] = c.r
	s[1] = c.g
	s[2] = c.b
	s[3] = c.a
}
