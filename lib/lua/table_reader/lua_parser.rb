# TODO license info for https://github.com/antlr/grammars-v4/blob/master/lua/Lua.g4

require 'parslet'


module Lua
  module TableReader
    class LuaParser < Parslet::Parser
      
      # Abstractions
      
      rule :document do
        space? >> expression >> space?
      end
      
      rule :expression do
        string | table | number
        # TODO 'nil' | 'false' | 'true' | number | '...' | functiondef | prefixexp | exp binop exp | unop exp
      end
      
      
      # Tables
      
      rule :table do
        str('{') >> space? >> field_list.maybe.as(:table) >> space? >> str('}')
      end
      
      rule :field_list do
        field >> space? >> (field_separator >> space? >> field >> space?).repeat >> field_separator.maybe
      end
      
      rule :field do
        str('[') >> space? >> expression.as(:key) >> str(']') >> space? >> str('=') >> space? >> expression.as(:value) |
        name.as(:str_key) >> space? >> str('=') >> space? >> expression.as(:value) |
        expression.as(:value)
      end
      
      rule :field_separator do
        match[',;']
      end
      
      
      # Strings
      
      rule :string do
        quoted_string | multiline_string
      end
      
      rule :quoted_string do
        %w{ ' " }.map do |quote|
          str(quote) >>
          (
            escape_sequence |
            (str('\\') | str(quote)).absent? >> any
          ).repeat.as(:string) >>
          str(quote)
        end.reduce {|union, atom| union | atom }
      end
      
      rule :multiline_string do
        str('[') >> str('=').repeat.capture(:multiline_equal_padding) >> str('[') >>
        (multiline_string_end_delimeter.absent? >> any).repeat.as(:string) >>
        multiline_string_end_delimeter
      end
      
      rule :multiline_string_end_delimeter do
        str(']') >> dynamic {|s, context| str(context.captures[:multiline_equal_padding]) } >> str(']')
      end
        
      
      # TODO add transformation for escape sequences
      rule(:escape_sequence) { char_escape | decimal_escape | hex_escape }
      rule(:char_escape) { str('\\') >> (match['abfnrtvz"\'\\\\'] | str('\r').maybe >> str('\n')) }
      rule(:decimal_escape) { str('\\') >> match['0-2'].maybe >> match('\d').repeat(1,2) }
      rule(:hex_escape) { str('\\x') >> hex_digit.repeat(2,2) }
      
      
      # Numbers
      
      rule(:number) { float | hex | int }
      
      rule(:int) { (str('-').maybe >> digits).as(:int) }
      rule(:hex) { (str('-').maybe >> hex_prefix >> hex_digits).as(:hex) }
      rule(:float) do
        ( str('-').maybe >> (
          digits >> str('.') >> digits.maybe >> float_exponent.maybe |
          str('.') >> digits >> float_exponent.maybe |
          digits >> float_exponent
        )).as(:float)
      end
      rule(:float_exponent) { match['eE'] >> match['+-'].maybe >> digits }
      
      rule(:digits) { match['0-9'].repeat(1) }
      rule(:hex_digit) { match['0-9a-fA-F'] }
      rule(:hex_digits) { hex_digit.repeat(1) }
      rule(:hex_prefix) { str('0') >> match['xX'] }
      
      
      # Misc
      
      rule(:name) { match['a-zA-Z_'] >> match['a-zA-Z0-9_'].repeat }
      
      rule(:space) { match('\s').repeat(1) }
      rule(:space?) { space.maybe }
      
      
      root :document
      
    end
  end
end
