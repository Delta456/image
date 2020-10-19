module image

import image.color


// YCbCrSubsampleRatio is the chroma subsample ratio used in a YCbCr image.
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
	sub_sample_ratio YCbCr_Subsample_Ratio
	rect Rectangle
}

pub fn (y YCbCr) color_model() color.Model {
	return color.new_ycbcr_model()
}

pub fn (y YCbCr) bounds() Rectangle {
	return y.rect
}

pub fn (p YCbCr) at(x int, y int) color.Color {
	return p.ybcbcr_at(x, y)
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

pub fn (p YCbCr) c_offset(x int, y int) int {
	match p.sub_sample_ratio {
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

