import image

fn test_rectangle() {
	rects := [
		image.new_rectangle(0, 0, 10, 10),
		image.new_rectangle(10, 0, 20, 10),
		image.new_rectangle(1, 2, 3, 4),
		image.new_rectangle(4, 6, 10, 10),
		image.new_rectangle(2, 3, 12, 5),
		image.new_rectangle(-1, -2, 0, 0),
		image.new_rectangle(-1, -2, 4, 6),
		image.new_rectangle(-10, -20, 30, 40),
		image.new_rectangle(8, 8, 8, 8),
		image.new_rectangle(88, 88, 88, 88),
		image.new_rectangle(6, 5, 4, 3)
	]

	for r in rects {
		for s in rects {
			got := r.eq(s)
			want := inside(r, s)
			want2 := inside(s, r)
			if got != want && got != want2 {
				eprintln('eq r=$r, s=$s: got $got, want $want')
				exit(1)
			}
		}
	}

}

fn inside(f, g image.Rectangle) bool {
	if !f.inside(g) {
		return false
	}
	for y := f.min.y; y < f.max.y; y++ {
			for x := f.min.x; x < f.max.x; x++ {
				p := image.Point{x, y}
				if !p.inside(g) {
					return false
				}
			}
	}
	return true

}
