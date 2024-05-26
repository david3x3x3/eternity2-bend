# join two lists together
def join(l1, l2):
  fold l1:
    case List/Cons:
      return List/Cons(l1.head, l1.tail)
    case List/Nil:
      return l2

# return the nth element in a list
def lindex(list, n):
  i = 0
  fold list with i:
    case List/Cons:
      if n == i:
        return list.head
      else:
        return list.tail(i+1)
    case List/Nil:
      return List/Nil

# return the first n items from a list
def headn(list, n):
  switch n:
    case 0:
      return List/Nil
    case _:
      match list:
        case List/Cons:
          return List/Cons(list.head, headn(list.tail, n-1))
        case List/Nil:
          return list
    
# return all items after the first n items
def tailn(list, n):
  switch n:
    case 0:
      return list
    case _:
      match list:
        case List/Cons:
          return tailn(list.tail, n-1)
        case List/Nil:
          return list
    
# filter a list of two element lists. produce a new list with the
# second values where the first value matches n in the original list
def filt(list, n):
  fold list:
    case List/Cons:
      if lindex(list.head, 0) == n:
        return List/Cons(lindex(list.head, 1), list.tail)
      else:
        return list.tail
    case List/Nil:
      return List/Nil

# rotate an array of 4 elements by num positions
def rot(range, piece_num, piece):
  rots = 0
  pp = join(piece, piece)
  fold range with rots:
    case List/Cons:
      return List/Cons([piece_num, rots, headn(tailn(pp, 4-rots), 4)], range.tail(rots+1))
    case List/Nil:
      return List/Nil

# take a piece and rotate it into 4 orientations
def rot4(list, num):
  return rot([0, 1, 2, 3], num, list)
  
# rotate all pieces in a list into all 4 rotations.  each element in
# the new list will look like [piece_num, rotations, [edge, edge,
# edge, edge]]
def rot_all(list):
  i = 1
  fold list with i:
    case List/Cons:
      return join(rot4(list.head, i), list.tail(i+1))
    case List/Nil:
      return List/Nil

# find the value of the top and left edges of each piece and prepend
# it to each piece in a list
def calc(list, max_edge):
  fold list:
    case List/Cons:
      data = lindex(list.head, 2)
      return List/Cons([lindex(data, 0)*(max_edge+1) + lindex(data, 3), list.head], list.tail)
    case List/Nil:
      return List/Nil

# make a list of the numbers 0 to n-1 in reverse
def jotr(n):
  switch n:
    case 0:
      return []
    case _:
      return List/Cons(n-1, jotr(n-1))

# reverse a list
def reverse(list):
  left = List/Nil
  fold list with left:
    case List/Cons:
      return list.tail(List/Cons(list.head, left))
    case List/Nil:
      return left
      
# make a list of the numbers from 0 to n-1
def jot(n):
  return reverse(jotr(n))

# take a list of numbered items and put them in a list with each
# number in separate slot
def build_table(num_size, p):
  nums = jot(num_size)
  fold nums:
    case List/Cons:
      return List/Cons(filt(p, nums.head), nums.tail)
    case List/Nil:
      return List/Nil

# return the maximum int in a list
def maxl(list):
  fold list:
    case List/Cons:
      lt = list.tail
      if list.head > lt:
        return list.head
      else:
        return lt
    case List/Nil:
      return 0

# return a list of max ints from a list of lists of ints
def maxll(list):
  fold list:
    case List/Cons:
      return List/Cons(maxl(list.head), list.tail)
    case List/Nil:
      return List/Nil

# return 0 if num is not in pieces; else 1
def dup_check(pieces, num):
  fold pieces:
    case List/Cons:
      if num == lindex(pieces.head, 0):
        return 1
      else:
        return pieces.tail
    case List/Nil:
      return 0

# keep squaring the var root and increasing if it doesn't match the square
def sqrt_try(root, square):
  if root*root == square:
    return root
  else:
    return sqrt_try(root+1, square)

# get the square root (of a small number known to be square)
def sqrt(square):
  return sqrt_try(0, square)

# get the length of a list
def llength(list):
  fold list:
    case List/Cons:
      return list.tail+1
    case List/Nil:
      return 0

# take a list of pieces that are known to fit with the pieces above
# and to the left.  perform remaining checks to see if they are valid
# and continue the search.
def search2(possible, pieces, table, max_edge, width, depth):
  fold possible:
    case List/Cons:
      piece = possible.head
      # check for dups
      if dup_check(pieces, lindex(piece, 0)) == 0:
        # check for edge not at right
        if (depth % width == width - 1) == (lindex(lindex(piece, 2), 1) == 0):
          # check for edge not at bottom
          if (depth / width == width - 1) == (lindex(lindex(piece, 2), 2) == 0):
            res = search(width, List/Cons(piece, pieces), table, max_edge, depth + 1)
            match res:
              case List/Cons:
                return List/Cons(res, possible.tail)
              case List/Nil:
                return possible.tail
          else:
            return possible.tail
        else:
          return possible.tail
      else:
        return possible.tail
    case List/Nil:
      return List/Nil

# combine a list of lists into a single list
def flatten(list):
  fold list:
    case List/Cons:
      return join(list.head, list.tail)
    case List/Nil:
      return List/Nil

# take the piece number and rotation from a list of pieces
def summary(list):
  fold list:
    case List/Cons:
      return List/Cons(headn(list.head, 2), list.tail)
    case List/Nil:
      return List/Nil

# find out which entry in our lookup table has pieces that match the
# upper and left edge
def search(width, start, table, max_edge, depth):
  match start:
    case List/Cons:
      if depth == width * width:
        return [reverse(headn(summary(start), width*width))]
      else:
        up = lindex(lindex(lindex(start, width - 1), 2), 2)
        left = lindex(lindex(lindex(start, 0), 2), 1)
        possible = lindex(table, up * (max_edge + 1) + left)
        return flatten(search2(possible, start, table, max_edge, width, depth))
    case List/nil:
      return List/Nil

# build a row of blank pieces at the start so that our first row can
# match edges against something

def build_start(width):
  range = jot(width)
  fold range:
    case List/Cons:
      return List/Cons([0, 0, [0, 0, 0, 0]], range.tail)
    case List/Nil:
      return List/Nil

def main():
  # 3x3
  # pieces = [[0,0,1,1],[0,0,1,2],[0,0,2,1],[0,0,2,2],[0,1,3,2],[0,1,4,1],[0,2,3,1],[0,2,4,2],[3,3,4,4]]
  # 4x4
  # pieces = [[0,0,1,1],[0,0,1,2],[0,0,2,1],[0,0,2,2],[0,1,3,1],[0,1,3,2],[0,1,4,1],[0,1,5,2],[0,2,4,1],[0,2,4,2],[0,2,5,1],[0,2,5,2],[3,3,5,5],[3,4,3,5],[3,4,4,4],[3,5,5,4]]
  # 5x5
  pieces = [[0,0,1,1],[0,0,2,1],[0,0,2,3],[0,0,3,1],[0,1,4,1],[0,1,4,3],[0,1,5,2],[0,1,5,3],[0,1,6,2],[0,2,5,2],[0,2,6,3],[0,2,7,3],[0,3,4,1],[0,3,6,1],[0,3,6,2],[0,3,7,2],[4,4,5,6],[4,5,4,6],[4,5,5,6],[4,5,7,7],[4,6,5,6],[4,6,7,7],[4,7,5,5],[5,6,7,7],[6,7,7,7]]
  # 6x6
  # pieces = [[0,0,1,1],[0,0,1,3],[0,0,2,2],[0,0,2,3],[0,1,6,1],[0,1,6,2],[0,1,8,1],[0,1,8,2],[0,1,8,3],[0,2,4,1],[0,2,5,1],[0,2,6,2],[0,2,6,3],[0,2,7,3],[0,3,4,2],[0,3,4,3],[0,3,5,1],[0,3,6,2],[0,3,7,1],[0,3,8,2],[4,4,7,5],[4,5,5,5],[4,5,8,8],[4,6,6,7],[4,6,7,8],[4,7,6,5],[4,7,7,5],[4,7,7,7],[4,8,5,6],[4,8,5,7],[4,8,7,6],[4,8,7,8],[5,6,5,7],[5,6,6,8],[5,6,7,8],[5,8,6,8]]
  # 7x7
  # pieces = [[0,0,1,2],[0,0,1,3],[0,0,2,1],[0,0,3,2],[0,1,5,1],[0,1,6,1],[0,1,6,3],[0,1,7,2],[0,1,8,2],[0,1,8,3],[0,2,4,2],[0,2,5,3],[0,2,7,2],[0,2,8,2],[0,2,8,3],[0,2,9,1],[0,2,9,3],[0,3,4,1],[0,3,4,2],[0,3,5,1],[0,3,6,1],[0,3,6,3],[0,3,8,3],[0,3,9,1],[4,4,5,8],[4,4,7,5],[4,4,7,7],[4,5,5,7],[4,5,8,5],[4,6,5,7],[4,6,7,6],[4,8,6,9],[4,8,7,7],[4,8,9,5],[4,8,9,6],[4,9,6,8],[4,9,8,5],[4,9,9,6],[5,5,8,7],[5,5,9,7],[5,6,7,7],[5,6,8,6],[5,6,9,9],[5,9,7,9],[6,7,9,8],[6,8,7,7],[6,8,8,7],[6,9,8,9],[6,9,9,7]]
  width = sqrt(llength(pieces))
  max_edge = maxl(maxll(pieces))
  rot_pieces = rot_all(pieces)
  table_size = (max_edge+1)*(max_edge+1)
  table = build_table(table_size, calc(rot_pieces, max_edge))
  start = List/Cons(lindex(lindex(table, 0), 0), build_start(width))
  return search(width, start, table, max_edge, 1)
