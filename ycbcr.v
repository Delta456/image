module image

import image.color

pub enum Ycbcr_subsample_ratio {
	ratio_444
	ratio_424
	ratio_420
	ratio_440
	ratio_411
	ratio_410
}

pub fn (y Ycbcr_subsample_ratio) str() string {
	match y {
		.ratio_444 {
			return 'ratio_444'
		}
		.ratio_424 {
			return 'ratio_424'
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

