def sort arr
  arr = arr.dup
  bits = arr.max.to_s(10).length
  bits.times { |bi|
    h = arr.map { 0 }
    arr.map { |v| h[v.to_s(10)[-1-bi].to_i]+=1 }
    h.length.times { |i|
      if i > 0 then h[i] += h[i-1] end
    }
    arr_m = arr.map { 0 }
    arr.reverse.each_with_index.map { |v, i|
      h[v.to_s(10)[-1-bi].to_i] -= 1
      arr_m[h[v.to_s(10)[-1-bi].to_i]] = arr[-1-i]
    }
    arr = arr_m
  }
  arr
end

t1 = Time.now
a = (0..1000000).map { |i| (rand*100).floor }
t2 = Time.now
a.sort
t3 = Time.now
p a.sort == sort(a)
p t2-t1
p t3-t2
