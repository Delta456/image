import image

const (
	rects = [
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
)

fn test_inside() {
	for r in rects {
		for s in rects {
			got := r.eq(s)
			want := inside(r, s)
			want2 := inside(s, r)
			if got != want && got != want2 {
				eprintln('eq r=$r, s=$s: got $got, want $want')
				assert false
			}
		}
	}
	assert true
}

fn test_intersection() {
	for r in rects {
		for s in rects {
			a := r.intersect(s)
			if !inside(a, r) {
				eprintln('intersect r=$r, s=$s, a=$a, a not in r')
				assert false
			}
			if !inside(a, s) {
				eprintln('intersect r=$r, s=$s, a=$a, a not in r')
				assert false
			}
			img := a == image.Rectangle{} 
			if img == r.overlaps(s) {
				eprintln('intersect r=$r, s=$s, a=$a, rect{} is same as overlaps')
				assert false
			}
			mut larger_than_a := [4]image.Rectangle{}
			larger_than_a[0] = a
			larger_than_a[1] = a
			larger_than_a[2] = a
			larger_than_a[3] = a

			larger_than_a[0].min.x--
			larger_than_a[1].min.y--
			larger_than_a[2].max.x--
			larger_than_a[3].min.y--

			for i, b in larger_than_a {
				if b.empty() {
					// b isn't actually larger than a.
					continue
				}
				if inside(b, r) && inside(b, s) {
					eprintln('intersect r=$r, s=$s, a=$a, b=$s, i=$i: intersection could be larger')
					assert false
				}
			}
			
		}
	}
	assert true
}


fn inside(f image.Rectangle, g image.Rectangle) bool {
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
