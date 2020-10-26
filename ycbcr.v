module image

import image.color

// YCbCrratio is the chroma subsample ratio used in a YCbCr image.
pub enum YCbCr_Subsample_Ratio {
	ratio_444
	ratio_422
	ratio_420
	ratio_440
	ratio_411
	ratio_410
}

pub fn (y YCbCr_Subsample_Ratio) str() string {
	match y {
		.ratio_444 {
			return 'ratio_444'
		}
		.ratio_422 {
			return 'ratio_422'
		}
		.ratio_420 {
			return 'ratio_420'
		}
		.ratio_440 {
			return 'ratio_440'
		}
		.ratio_411 {
			return 'ratio_411'
		}
		.ratio_410 {
			return 'ratio_410'
		}
	}
	return 'ratio_unknown'
}

// YCbCr is an in-memory image of Y'CbCr colors. There is one Y sample per
// pixel, but each Cb and Cr sample can span one or more pixels.
// YStride is the Y slice index delta between vertically adjacent pixels.
// CStride is the Cb and Cr slice index delta between vertically adjacent pixels
// that map to separate chroma samples.
// It is not an absolute requirement, but YStride and len(Y) are typically
// multiples of 8, and:
//	For 4:4:4, CStride == YStride/1 && len(Cb) == len(Cr) == len(Y)/1.
//	For 4:2:2, CStride == YStride/2 && len(Cb) == len(Cr) == len(Y)/2.
//	For 4:2:0, CStride == YStride/2 && len(Cb) == len(Cr) == len(Y)/4.
//	For 4:4:0, CStride == YStride/1 && len(Cb) == len(Cr) == len(Y)/2.
//	For 4:1:1, CStride == YStride/4 && len(Cb) == len(Cr) == len(Y)/4.
//	For 4:1:0, CStride == YStride/4 && len(Cb) == len(Cr) == len(Y)/8.
struct YCbCr {
	y []byte
	cb []byte
	cr []byte
	ystride int
	cstride int
	ratio YCbCr_Subsample_Ratio
	rect Rectangle
}

pub fn (y YCbCr) color_model() color.Model {
	return color.new_ycbcr_model()
}

pub fn (y YCbCr) bounds() Rectangle {
	return y.rect
}

pub fn (p YCbCr) at(x int, y int) color.Color {
	res := p.ybcbcr_at(x, y) // temporary workaround for now
	return res
}

pub fn (yb YCbCr) ybcbcr_at(x int, y int) color.YCbCr {
	p := Point{x, y}
	if !p.inside(yb.rect) {
		color.YCbCr{}
	}
	yi := yb.y_offset(x, y)
	ci := yb.c_offset(x, y)
	return color.YCbCr{
		yb.y[yi],
		yb.cb[ci],
		yb.cr[ci],
	}
}

// y_offset returns the index of the first element of Y that corresponds to
// the pixel at (x, y).
pub fn (p YCbCr) y_offset(x int, y int) int {
	return (y-p.rect.min.y)*p.ystride + (x - p.rect.min.x)
}

// c_offset returns the index of the first element of Cb or Cr that corresponds
// to the pixel at (x, y).
pub fn (p YCbCr) c_offset(x int, y int) int {
	match p.ratio {
		.ratio_422 {
			return (y-p.rect.min.y)*p.cstride + (x/2 - p.rect.min.x/2)
		}
		.ratio_420 {
			return (y/2-p.rect.min.y/2)*p.cstride + (x/2 - p.rect.min.x/2)
		}
		.ratio_440 {
			return (y/2-p.rect.min.y/2)*p.cstride + (x - p.rect.min.x)
		}
		.ratio_411 {
			return (y-p.rect.min.y)*p.cstride + (x/4 - p.rect.min.x/4)
		}
		.ratio_410 {
			return (y/2-p.rect.min.y/2)*p.cstride + (x/4 - p.rect.min.x/4)
		}
		else {
			// Default to 4:4:4 subsampling.
			return (y-p.rect.min.y)*p.cstride + (x - p.rect.min.x)
		}
	}
}

pub fn (p YCbCr) opaque() bool {
	return true
}

// sub_img returns an image representing the portion of the image p visible
// through r. The returned value shares pixels with the original image.
pub fn (p YCbCr) sub_img(r Rectangle) Image {
	r1 := r.intersect(p.rect)
	// If r1 and r2 are Rectangles, r1.Intersect(r2) is not guaranteed to be inside
	// either r1 or r2 if the intersection is empty. Without explicitly checking for
	// this, the Pix[i:] expression below can panic.
	if r1.empty() {
		return &YCbCr{
			ratio: p.ratio,
		}
	}
	yi := p.y_offset(r1.min.x, r.min.y)
	ci := p.c_offset(r1.min.x, r.min.y)
	return &YCbCr{
		y:              p.y[yi..],
		cb:             p.cb[ci..],
		cr:             p.cr[ci..],
		ratio:          p.ratio,
		ystride:        p.ystride,
		cstride:        p.cstride,
		rect:           r1,
	}

}

fn ycbcr_size(r Rectangle, ratio YCbCr_Subsample_Ratio) (int, int, int, int) {
	w, h := r.dx(), r.dy()
	mut cw, mut ch := int(0), int(0)
	match ratio {
		.ratio_422 {
			cw = (r.max.x+1)/2 - r.min.x/2
			ch = h
		}
		.ratio_420 {
			cw = (r.max.x+1)/2 - r.min.x/2
			ch = (r.max.y+1)/2 - r.min.y/2
		}
		.ratio_440 {
			cw = w
			ch = (r.max.y+1)/2 - r.min.y/2
		}
		.ratio_411 {
			cw = (r.max.x+3)/4 - r.min.x/4
			ch = h
		}
		.ratio_410 {
			cw = (r.max.x+3)/4 - r.min.x/4
			ch = (r.max.y+1)/2 - r.min.y/2
		}
		else {
			// Default to 4:4:4 subsampling.
			cw = w
			ch = h
		}
	}
	return w, h, cw, ch
}

// new_ycbcr returns a new YCbCr image with the given bounds and subsample
// ratio.
pub fn new_ycbcr(r Rectangle, ratio YCbCr_Subsample_Ratio) &YCbCr {
	w, h, cw, ch := ycbcr_size(r, ratio)

	// total_length should be the same as i2, below, for a valid Rectangle r.
	total_length := add2_nonneg(
		mul3_nonneg(1, w, h),
		mul3_nonneg(2, cw, ch),
	)
	if total_length < 0 {
		panic("image: new_ycbcr Rectangle has huge or negative dimensions")
	}

	i0 := w*h + 0*cw*ch
	i1 := w*h + 1*cw*ch
	i2 := w*h + 2*cw*ch
	b := []byte{ init: i2 }
	return &YCbCr{
		y:              b[..i0],
		cb:             b[i0..i1],
		cr:             b[i1..i2],
		ratio: ratio,
		ystride:        w,
		cstride:        cw,
		rect:           r,
	}
}
