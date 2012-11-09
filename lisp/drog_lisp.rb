
require 'whittle'

$symbol_table = {}

class LispMaker < Whittle::Parser

  rule(:wsp => /\s+/).skip! #skip whitespace

  rule("(")
  rule(")")

  rule(:add => /Add/).as { |add| add }
  rule(:mul => /Mul/).as { |mul| mul }
  rule(:sub => /Sub/).as { |sub| sub }
  rule(:def => /Def/).as { |d|     d }
  rule(:get => /Get/).as { |g|     g }
  rule(:let => /Let/).as { |l|     l }
  rule(:name => /[a-zA-Z]+/).as { |n| n }
  rule(:constant => /[0-9]+/).as { |c| c.to_i }

  rule(:expr) do |r|
    r["(", :constant, ")"].as { |_, n, _| n }
    r["(", :add, :expr, :expr, ")"].as { |_,_,n1,n2,_| n1 + n2 }
    r["(", :mul, :expr, :expr, ")"].as { |_,_,n1,n2,_| n1 * n2 }
    r["(", :sub, :expr, :expr, ")"].as { |_,_,n1,n2,_| n1 - n2 }
    r["(", :let, :definition, :expr].as { |_,_,_,n| n }
    r["(", :get, :name, ")"].as { |_,_,n,_| $symbol_table[n] }
    r[]
  end

  rule(:definition) do |r|
    r["(", :def, :name, :expr, ")"].as do |_,_,n1,n2,_|
      $symbol_table[n1] = n2
      nil
    end
  end

  start(:expr)
end

puts LispMaker.new.parse(File.new(ARGV[0]).read)