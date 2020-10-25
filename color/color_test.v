import color

fn test_sqdiff() {
	cases := [
		u32(0), 
		1,
		2,
		0x0fffd,
		0x0fffe,
		0x0ffff,
		0x10000,
		0x10001,
		0x10002,
		0xfffffffd,
		0xfffffffe,
		0xffffffff,
		]
	for _, x in cases {
		for _, y in cases {
			got, want := color.sq_diff(x,y) , orig(x, y)
			if got != want {
				eprintln('sq_diff($x, $y): got $got want $want')
				assert false
			}
		}
	}
	assert true
}

// canonical color.sq_diff implementation
fn orig(x u32, y u32) u32 {
	mut d := u32(0)
	if x > y {
		d = u32(x - y)
	} else {
		d = u32(y - x)
	}
	return (d * d) >> 2
}
