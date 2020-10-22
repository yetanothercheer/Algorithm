def sort arr
  (0...arr.length).map { m,i=arr.each_with_index.min; arr[i]=999; m }
end

a = (1..100).map { (rand*100).floor }
p sort a
p a.sort == sort(a)

