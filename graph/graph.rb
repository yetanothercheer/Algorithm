require "test/unit/assertions"
include Test::Unit::Assertions

# Shortest path using dynamic programming

Point = Struct.new :name
Vertex = Struct.new :a, :b

def P name
  Point.new name
end

def V a, b
  Vertex.new a, b
end

def shortest_path ps, vs, a, b
  if a == b then return 0 end
  # Let's pretend that 999 is really big.
  if vs.empty? then return 999 end
  # Next line not work. Why?
  # connected = Hash.new []
  connected = []
  vs.each do |v|
    if v.a == b then connected << v.b end
    if v.b == b then connected << v.a end
  end
  connected.map { |p| shortest_path vs.filter { |v| v != b }, vs.filter { |v| v.a != b && v.b != b }, a, p  }.min + 1
end

a = P "a"
b = P "b"
c = P "c"
d = P "d"
assert_equal 1, shortest_path([a, b, c], [V(a, c), V(a, b), V(b, c)], a, c)
assert_equal 1, shortest_path([a, b, c], [V(a, c)], a, c)
assert_equal 1, shortest_path([a, b, c], [V(a, c)], a, c)
assert_equal 3, shortest_path([a, b, c, d], [V(a, b), V(b, c), V(c, d)], a, d)
assert_equal 1, shortest_path([a, b, c, d], [V(a, d), V(a, b), V(b, c), V(c, d)], a, d)
