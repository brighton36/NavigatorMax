#!/usr/bin/env ruby
# encoding: UTF-8

class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end

# TODO: Maybe create a Matrix3x3 class?
class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end

  def normalize
    ret = m3x3
    0.upto(2) do |i|
      length = Math.sqrt(self[i, 0] * self[i, 0] + self[i, 1] * self[i, 1] + self[i, 2] * self[i, 2])
      if length == 0.0
        ret[i, 0] = 0
        ret[i, 1] = 0
        ret[i, 2] = 0
      else
        ret[i, 0] = self[i, 0] / length
        ret[i, 1] = self[i, 1] / length
        ret[i, 2] = self[i, 2] / length
      end
    end

    ret
  end
end

# TODO: Clean this up, and maybe create a V3 class?
class Vector
  def x; self.send :[], 0; end
  def y; self.send :[], 1; end
  def z; self.send :[], 2; end
  def x=(v); self.send :[]=, 0, v; end
  def y=(v); self.send :[]=, 1, v; end
  def z=(v); self.send :[]=, 2, v; end

  def []=(i,n); @elements[i] = n; end

  def v3_crossproduct(vB)
    cross = v3(0,0,0)
    cross.x = y * vB.z - z * vB.y
    cross.y = z * vB.x - x * vB.z
    cross.z = x * vB.y - y * vB.x
    cross
  end

  def v3_dotproduct(vB)
    x * vB.x + y * vB.y + z * vB.z
  end
end

def v3(x, y, z)
  Vector[x,y,z]
end

def m3x3
 Matrix.build(3,3){0}
end
