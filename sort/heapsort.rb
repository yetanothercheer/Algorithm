def sort arr
  swap = lambda { |i, j| i_temp = arr[i]; arr[i] = arr[j]; arr[j] = i_temp }
  insert = lambda { |i|
    if i == 0 then return end
    p = (i-1) / 2
    if arr[p] > arr[i] then swap.(p, i); insert.(p) end
  }
  # Build heap
  arr.length.times { |i| insert.(i) }
  heap_size = arr.length

  down_heap = lambda { |i|
    l = i * 2 + 1
    r = l + 1
    if l > heap_size - 1 then
      return
    elsif l == heap_size - 1 then
      if arr[i] > arr[l] then swap.(i, l) end
    else
      if arr[i] > arr[l] || arr[i] > arr[r] then to=if arr[l]>arr[r] then r else l end; swap.(i,to); down_heap.(to) end
    end
  }

  extract = lambda {
    swap.(0, heap_size - 1)
    heap_size -= 1
    down_heap.(0)
    arr[heap_size]
  }

  # Same as selection sort
  (0...arr.length).map { extract.() }
end

a = (1..100).map { (rand*100).floor }
p a.sort == sort(a)
