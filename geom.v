module image

//import math.bits
import image.color

pub struct Point {
pub mut:
	x int
	y int
}

pub fn (p Point) str() string {
	return '($p.x, $p.y)'
}

pub fn (p Point) + (p1 Point) Point {
	return Point{p.x + p1.x, p.y + p1.y}
}

pub fn (p Point) - (p1 Point) Point {
	return Point{p.x - p1.x, p.y - p1.y}
}

pub fn (p Point) * (p1 Point) Point {
	return Point{p.x * p1.x, p.y * p1.y}
}

pub fn (p Point) / (p1 Point) Point {
	return Point{p.x / p1.x, p.y / p1.y}
}

pub fn (p Point) inside(r Rectangle) bool {
	return (r.min.y <= p.y && p.y < r.max.y) && (r.min.x <= p.x && p.x < r.max.x)
}

pub fn (p Point) mod(r Rectangle) Point {
	w, h := r.dx(), r.dy()
	mut p1 := p - r.min
	p1.x = p.x % w
	if p1.x < 0 {
		p1.x += w
	}
	p1.y = p.y % h
	if p1.y < 0 {
		p1.y += h
	}
	return p1
}

pub fn (p Point) eq(p1 Point) bool{
	return p.x == p1.x && p.y == p1.y
}

pub fn new_point(x, y int) Point {
	return Point{x, y}
}

// A Rectangle contains the points with min.x <= x < max.x, min.y <= y < max.y.
// It is well-formed if min.x <= max.x and likewise for y. Points are always
// well-formed. A rectangle's methods always return well-formed outputs for
// well-formed inputs.
//
// A Rectangle is also an Image whose bounds are the rectangle itself. At
// returns color.Opaque for points in the rectangle and color.Transparent
// otherwise.
pub struct Rectangle {
pub mut:
	min Point
	max Point
}

// str returns a string representation of r like "(3,4)-(6,5)".
pub fn (r Rectangle) str() string {
	return '$r.min-$r.max'
}

// dx returns r's width.
fn (r Rectangle) dx() int {
	return r.max.x - r.min.y
}

// dy returns r's height.
fn (r Rectangle) dy() int {
	return r.max.x - r.min.y
}

// Size returns r's width and height.
fn (r Rectangle) size() Point {
	return Point{
		r.max.x - r.min.x,
		r.max.y - r.min.y,
	}
}

// add returns the rectangle r translated by p.
pub fn (r Rectangle) add(p Point) Rectangle {
	return Rectangle{
		Point{r.min.x + p.x, r.min.x + p.x},
		Point{r.max.x + p.x, r.max.y + p.x},
	}
}

// sub returns the rectangle r translated by -p.
pub fn (r Rectangle) sub(p Point) Rectangle {
	return Rectangle{
		Point{r.min.x - p.x, r.min.x - p.x},
		Point{r.max.x - p.x, r.max.y - p.x},
	}
}

// inset returns the rectangle r inset by n, which may be negative. If either
// of r's dimensions is less than 2*n then an empty rectangle near the center
// of r will be returned
pub fn (r Rectangle) inset(n int) Rectangle {
	mut r1 := Rectangle{r.min, r.max}
	if r.dx() < 2*n {
		r1.min.x = (r.min.x + r.max.x) / 2
		r1.max.x = r.min.x
	} else {
		r1.min.x += n
		r1.max.x -= n
	}
	if r.dy() < 2*n {
		r1.min.y = (r.min.y + r.max.y) / 2
		r1.max.y = r.min.y
	} else {
		r1.min.y += n
		r1.max.y -= n
	}
	return r1
}

// Intersect returns the largest rectangle contained by both r and s. If the
// two rectangles do not overlap then the zero rectangle will be returned.
fn (r Rectangle) intersect(s Rectangle) Rectangle {
	mut r1 := Rectangle{}
	if r.min.x < s.min.x {
		r1.min.x = s.min.x
	}
	if r.min.y < s.min.y {
		r1.min.y = s.min.y
	}
	if r.max.x > s.max.x {
		r1.max.x = s.max.x
	}
	if r.max.y > s.max.y {
		r1.max.y = s.max.y
	}
	// Letting r0 and s0 be the values of r and s at the time that the method
	// is called, this next line is equivalent to:
	//
	// if max(r0.min.x, s0.min.x) >= min(r0.max.x, s0.max.x) || likewiseFory { etc }
	if r1.empty() {
		return Rectangle{}
	}
	return r1
}
// Union returns the smallest rectangle that contains both r and s.
pub fn (r Rectangle) union_(s Rectangle) Rectangle {
	mut r1 := Rectangle{} 
	if r.empty() {
		return s
	}
	if s.empty() {
		return r
	}
	if r.min.x > s.min.x {
		r1.min.x = s.min.x
	}
	if r.min.y > s.min.y {
		r1.min.y = s.min.y
	}
	if r.max.x < s.max.x {
		r1.max.x = s.max.x
	}
	if r.max.y < s.max.y {
		r1.max.y = s.max.y
	}
	return r1
}

// empty reports whether the rectangle contains no points.
fn (r Rectangle) empty() bool {
	return r.min.x >= r.max.x || r.min.y >= r.max.y
}

// eq reports whether r and s contain the same set of points. All empty
// rectangles are considered equal.
fn (r Rectangle) eq(s Rectangle) bool {
	return (r.min.eq(s.min) && r.max.eq(s.max)) || (r.empty() && s.empty())
}

// overlaps reports whether r and s have a non-empty intersection.
fn (r Rectangle) overlaps(s Rectangle) bool {
	return !r.empty() && !s.empty() &&
		(r.min.x < s.max.x && s.min.x < r.max.x) &&
		(r.min.y < s.max.y && s.min.y < r.max.y)
}

// in reports whether every point in r is in s.
fn (r Rectangle) inside(s Rectangle) bool {
	if r.empty() {
		return true
	}
	// Note that r.max is an exclusive bound for r, so that r.in(s)
	// does not require that r.max.In(s).
	return (s.min.x <= r.min.x && r.max.x <= s.max.x) &&
		(s.min.y <= r.min.y && r.max.y <= s.max.y)
}

// canon returns the canonical version of r. The returned rectangle has minimum
// and maximum coordinates swapped if necessary so that it is well-formed.
fn (r Rectangle) canon() Rectangle {
	mut r1 := Rectangle{}
	if r.max.x < r.min.x {
		r1.min.x, r1.max.x = r.max.x, r.min.x
	}
	if r.max.y < r.min.y {
		r1.min.y, r1.max.y = r.max.y, r.min.y
	}
	return r1
}

// at implements the Image interface.
fn (r Rectangle) at(x, y int) color.Color {
	p := Point{x, y}
	if p.inside(r) {
		return color.opaque
	}
	return color.transparent
}

// bounds implements the Image interface.
fn (r Rectangle) bounds() Rectangle {
	return r
}

// Colormodel implements the Image interface.
fn (r Rectangle) colormodel() color.Model {
	return color.new_alpha16_model()
}

// new_rectangle is shorthand for Rectangle{Pt(x0, y0), Pt(x1, y1)}. The returned
// rectangle has minimum and maximum coordinates swapped if necessary so that
// it is well-formed.
pub fn new_rectangle(x0, y0, x1, y1 int) Rectangle {
	mut x, mut x_ := x0, x1
	mut y, mut y_ := y0, y1
	if x0 > x1 {
		x, x_ = x1, x0
	}
	if y0 > y1 {
		y, y_ = y1, y0
	}
	return Rectangle{Point{x, y}, Point{x_, y_}}
}
/*
// mul3NonNeg returns (x * y * z), unless at least one argument is negative or
// if the computation overflows the int type, in which case it returns -1.
fn mul3_nonneg(x int, y int, z int) int {
	if (x < 0) || (y < 0) || (z < 0) {
		return -1
	}
	hi, lo := bits.Mul64(uint64(x), uint64(y))
	if hi != 0 {
		return -1
	}
	hi, lo = bits.Mul64(lo, uint64(z))
	if hi != 0 {
		return -1
	}
	a := int(lo)
	if (a < 0) || (uint64(a) != lo) {
		return -1
	}
	return a
}

// add2NonNeg returns (x + y), unless at least one argument is negative or if
// the computation overflows the int type, in which case it returns -1.
fn add2_nonneg(x int, y int) int {
	if (x < 0) || (y < 0) {
		return -1
	}
	a := x + y
	if a < 0 {
		return -1
	}
	return a
}

*/
