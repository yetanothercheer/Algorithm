def shorted_path g, a, b
  visited = []
  current = a
  unvisited = (0...g.length).map { |i| if i == a then [i, 0] else [i, 999] end }
  loop {
    p current
    len = unvisited.filter { |u| u[0] == current }[0][1]
    unvisited = unvisited.map { |u| new_dist = len + g[current][u[0]]; if !visited.include?(u[0]) && new_dist < u[1] then [u[0], new_dist] else u end }.filter { |u| u[0] != current }
    visited << current
    if visited.include?(b) then break end
    min = unvisited.min_by { |u| u[1] }
    current = min[0]
  }
end


# Let's use a 2D array to represent graph.
graph = [
  [0, 1, 0],
  [1, 0, 1],
  [0, 1, 0]
]
shorted_path graph, 0, 2


