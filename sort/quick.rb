def sort arr
  if arr.length <= 1 then return arr end
  partition = lambda do |arr|
    left, right = [], []
    arr[0..-2].each do |e| if e < arr[-1] then left << e else right << e end end
    return left, [arr[-1]], right
  end
  left, center, right = partition.(arr)
  sort(left) + center + sort(right)
end

arr = (1..10000).map { (rand*10000).floor }

p arr.sort == sort(arr)
