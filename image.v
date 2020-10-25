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

// pixel_buffer_length returns the length of the []byte typed Pix slice field
// for the new_xxx functions. Conceptually, this is just (bpp * width * height),
// but this function panics if at least one of those is negative or if the
// computation would overflow the int type.
//
// This panics instead of returning an error because of backwards
// compatibility. The new_xxx functions do not return an error.
fn pixel_buffer_length(bytes_per_pixel int, r Rectangle, img_type_name string) int {
	total_length := mul3_nonneg(bytes_per_pixel, r.dx(), r.dy())
	if total_length < 0 {
		panic("image: New $img_type_name Rectangle has huge or negative dimensions")
	}
	return total_length
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

// sub_img returns an image representing the portion of the image p visible
// through r. The returned value shares pixels with the original image.
pub fn (r RGBA) sub_img(r1 Rectangle) Image {
	rect := r1.intersect(r.rect)
	// If r1 and r2 are Rectangles, r1.intersect(r2) is not guaranteed to be inside
	// either r1 or r2 if the intersection is empty. Without explicitly checking for
	// this, the pix[i:] expression below can panic.
	if rect.empty() {
		return &RGBA{}
	}
	i := r.pix_offset(r1.min.x, r1.min.y)
	return &RGBA{
		pix:    r.pix[i..],
		stride: r.stride,
		rect:   r1,
	}
}

// opaque scans the entire image and reports whether it is fully opaque.
pub fn (r RGBA) opaque() bool {
	if r.rect.empty() {
		return true
	}
	mut i0, mut i1 := 3, r.rect.dx()*4
	for y := r.rect.min.y; y < r.rect.max.y; y++ {
		for i := i0; i < i1; i += 4 {
			if r.pix[i] != 0xff {
				return false
			}
		}
		i0 += r.stride
		i1 += r.stride
	}
	return true
}

// new_rgba returns a new RGBA image with the given bounds.
pub fn new_rgba(r Rectangle) &RGBA {
	return &RGBA{
		pix:    []byte{init: pixel_buffer_length(4, r, "RGBA")},
		stride: 4 * r.dx(),
		rect:   r,
	}
}
