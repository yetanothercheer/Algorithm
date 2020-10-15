def sort arr
  count = arr.map { 0 }
  arr.map { |elem| count[elem]+=1 }
  sorted = []
  count.each_with_index.map { |elem, index| elem.times { sorted << index }}
  sorted
end

a = (0...1000000).map { (rand*100).floor }
t1 = Time.now
sort a
t2 = Time.now
a.sort
t3 = Time.now
p sort(a) == a.sort
p t2-t1, t3-t2
