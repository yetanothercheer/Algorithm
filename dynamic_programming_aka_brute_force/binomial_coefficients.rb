# (n_k) = n!/(n-k)! / k!
# (n_k) = (n-1_k)*...
# Or goes to k-1, same story.
def bc n, k
  if n < k then
    0
  elsif n == k then
    1
  else
    # Easy to write from formula
    # But non-intuitive
    # An example tells me:
    #   you got n times what you had before
    #   and each arrangement repeats exactly n-k times!
    bc(n-1,k) * n / (n-k)
  end
end

# From the book The Algorithm Design Manual
# (n_k) = (n-1_k-1) + (n-1_k)
def bc2 n, k
  dp = {}
  (0..n).each { |i| dp[i] = Hash.new 0 }
  (0..n).each { |i| dp[i][0] = 1 }
  (0..n).each { |i| dp[i][i] = 1 }
  (1..n).each { |i|
    (1...i).each { |j|
      dp[i][j] = dp[i-1][j-1]+dp[i-1][j]
    }
  }
  dp[n][k]
end

def record name, &func
  start = Time.now
  func.call
  puts "#{name}\t#{Time.now-start}"
end

record "My Recursion" do bc(1000, 100) end
record "The Book" do bc2(1000, 100) end
