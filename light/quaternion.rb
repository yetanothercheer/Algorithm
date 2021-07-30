# Quaternion
# https://math.stackexchange.com/questions/3982756/quaternions-as-rotations-notation
# http://graphics.stanford.edu/courses/cs348a-17-winter/Papers/quaternion.pdf

def dot(a, b)
  a.zip(b).map { |first, second| first * second }.reduce(0, :+)
end

def cross(a, b)
  [a[1] * b[2] - b[1] * a[2], -(a[0] * b[2] - b[0] * a[2]), a[0] * b[1] - b[0] * a[1]]
end

def norm(a)
  Math.sqrt(dot(a, a))
end

def normalize(a)
  n = norm(a)
  a.map { |x| x / n }
end

class Qn
  attr_accessor :n, :x, :y, :z

  def initialize(n, x, y, z)
    @n, @x, @y, @z = n, x, y, z
  end

  def self.act(v, axis, theta)
    v = Qn.new(0, v[0], v[1], v[2])
    axis = normalize(axis)
    q = Qn.new(Math.cos(theta / 2), 0, 0, 0) + Qn.new(0, axis[0], axis[1], axis[2]).times(Math.sin(theta / 2))
    q * v * q.conjugate
  end

  def conjugate
    Qn.new(@n, -@x, -@y, -@z)
  end

  def vector
    [@x, @y, @z]
  end

  def +@
    self
  end

  def -@
    Qn.new(-@n, -@x, -@y, -@z)
  end

  def +(that)
    Qn.new(@n + that.n, @x + that.x, @y + that.y, @z + that.z)
  end

  def -(that)
    self + (-that)
  end

  def times(a)
    Qn.new(n * a, x * a, y * a, z * a)
  end

  def *(that)
    n = @n * that.n - dot(vector, that.vector)
    c = cross(vector, that.vector)
    x = @n * that.x + that.n * @x + c[0]
    y = @n * that.y + that.n * @y + c[1]
    z = @n * that.z + that.n * @z + c[2]
    Qn.new(n, x, y, z)
  end

  def self.Zero
    Qn.new(0, 0, 0, 0)
  end

  def self.One
    Qn.new(1, 1, 1, 1)
  end

  def self.Random
    Qn.new(Random.rand, Random.rand, Random.rand, Random.rand)
  end

  def to_s
    "  Quaternion [#{n.round 2} #{x.round 2} #{y.round 2} #{z.round 2}]"
  end
end

puts "Rotate [1, 0, 0] 90 degrees anti-clockwise by z axis"
puts Qn.act([1, 0, 0], [0, 0, 1], Math::PI / 2)

puts "Rotate [1, 0, 0] to [1, 1, 1]"
puts Qn.act([1, 0, 0], [0, 0, 1], Math::PI / 4)
puts Qn.act([Math.sqrt(2)/2, Math.sqrt(2)/2, 0], [1, -1, 0], Math.atan(Math.sqrt(0.5)))
