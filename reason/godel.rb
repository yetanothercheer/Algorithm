#
# Gödel's original paper:
# https://web.archive.org/web/20180303152436/http://www.research.ibm.com/people/h/hirzel/papers/canon00-goedel.pdf
#
# http://www.goodmath.org/blog/2014/08/26/godel-numbering/
#

# Logic inference in arithmetic, immediate consequence only

require 'prime'

# Didn't find a way to index prime :(
class Prime
  # Prime.at(1) = 2, not starting with 0
  def at(index)
    Prime.first(index)[-1]
  end
end

# Numbering
ZERO = 1
SUCC = 3
NOT  = 5
OR   = 7
FORALL = 9
LPAREN = 11
RPAREN = 13

# Numbering Variable
def Variable(index, type)
  Prime.at(7 + index) ** type
end

X1 = Variable(0, 1)
X2 = Variable(0, 2)
Y2 = Variable(1, 2)

# FORALL x1 ( y2(x1) OR x2(x1) )
F = [FORALL, X1, LPAREN, Y2, LPAREN, X1, RPAREN, OR, X2, LPAREN, X1, RPAREN, RPAREN]

# NOT x2(x1) OR y2(x1)
A = [NOT, X2, LPAREN, X1, RPAREN, OR, Y2, LPAREN, X1, RPAREN]
# x2(x1)
B = [X2, LPAREN, X1, RPAREN]
# y2(x1)
C = [Y2, LPAREN, X1, RPAREN]

def formula_to_number(formula)
  formula.zip(Prime.first(formula.length)).map { |f, p|
    p ** f
  }.reduce(1, :*)
end

def length(number)
  (1...number).find { |x|
    number % Prime.at(x) == 0 and number % Prime.at(x + 1) != 0
  }
end

def number_to_formula(number)
  Prime.first(length(number)).map { |p|
    (1..number).find { |x|
      number % (p ** x) == 0 and number % (p ** (x + 1)) != 0
    }
  }
end

def composite(*numbers)
  new_formula = numbers.map { |n|
    number_to_formula(n)
  }.reduce(:+)
  formula_to_number(new_formula)
end

# Immediate consequence
def Imp?(a, b, c)
  # (not b) or C
  imp = composite(2 ** NOT, b, 2 ** OR, c)
  a == imp
end

a = formula_to_number(A)
b = formula_to_number(B)
c = formula_to_number(C)
puts Imp?(a, b, c)
