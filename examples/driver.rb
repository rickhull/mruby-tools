SIMPLEX_PARAMS = [
  # 1 (index 0)
  [[1, 1],
   [[2,  1],
    [1,  2]],
   [4, 3]],

  [[3, 4],
   [[1, 1],
    [2, 1]],
   [4, 5]],

  [[2, -1],
   [[1, 2],
    [3, 2],],
   [6, 12]],

  [[60, 90, 300],
   [[1, 1, 1],
    [1, 3, 0],
    [2, 0, 1]],
   [600, 600, 900]],

  # 5
  [[70, 210, 140],
   [[1, 1, 1],
    [5, 4, 4],
    [40, 20, 30]],
   [100, 480, 3200]],

  [[2, -1, 2],
   [[2, 1, 0],
    [1, 2, -2],
    [0, 1, 2]],
   [10, 20, 5]],

  [[11, 16, 15],
   [[1, 2, 3.to_f / 2],
    [2.to_f / 3, 2.to_f / 3, 1],
    [0.5, 1.to_f / 3, 0.5]],
   [12_000, 4_600, 2_400]],

  [[5, 4, 3],
   [[2, 3, 1],
    [4, 1, 2],
    [3, 4, 2]],
   [5, 11, 8]],

  [[3, 2, -4],
   [[1, 4, 0],
    [2, 4,-2],
    [1, 1,-2]],
   [5, 6, 2]],

  # 10
  [[2, -1, 8],
   [[2, -4, 6],
    [-1, 3, 4],
    [0, 0, 2]],
   [3, 2, 1]],

  [[100_000, 40_000, 18_000],
   [[20, 6, 3],
    [0, 1, 0],
    [-1,-1, 1],
    [-9, 1, 1]],
   [182, 10, 0, 0]],

  [[1, 2, 1, 2],
   [[1, 0, 1, 0],
    [0, 1, 0, 1],
    [1, 1, 0, 0],
    [0, 0, 1, 1]],
   [1, 4, 2, 2]],

  [[10, -57, -9, -24],
   [[0.5, -5.5, -2.5, 9],
    [0.5, -1.5, -0.5, 1],
    [ 1,    0,    0, 0]],
   [0, 0, 1]],

  # 14 (index 13)
  [[25, 20],
   [[20, 12],
    [1, 1]],
   [1800, 8*15]],
]

def simplices
  SIMPLEX_PARAMS.map { |c, a, b| Simplex.new(c, a, b) }
end

puts "calculating #{SIMPLEX_PARAMS.size} simplex solutions, repeatedly..."
val, elapsed = Timer.loop_avg {
  simplices.map { |s| s.solution }.join("\n")
}

puts "%0.8f s (avg) per solution" % (elapsed / SIMPLEX_PARAMS.size)