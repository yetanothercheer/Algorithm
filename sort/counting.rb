def sort arr
  count = [0] * arr.length
  arr.map { |elem| count[elem]+=1 }
  # Very inefficient but satisfiable
  count.each_with_index.map { |elem, index| [index] * elem }.reduce { |r, a| r + a }
end

a = (0...100).map { (rand*100).floor }
t1 = Time.now
sort a
t2 = Time.now
a.sort
t3 = Time.now
p sort(a) == a.sort
p t2-t1, t3-t2
