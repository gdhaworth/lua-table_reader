# TODO license info for https://github.com/antlr/grammars-v4/blob/master/lua/Lua.g4

require 'parslet'


module Lua
  module TableReader
    class LuaParser < Parslet::Parser
      
      # Abstractions
      
      rule :document do
        (space? >> top_level_table).repeat.as(:tables) >> space?
      end
      
      rule :top_level_table do
        # This is not a real Lua concept, its merely to facilitate the design to only read tables
        name.as(:table_name) >> space? >> str('=') >> space? >> table.as(:table_definition)
      end
      
      rule :expression do
        string | table | number | value_keyword
        # TODO '...' | functiondef | prefixexp | exp binop exp | unop exp
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
          ).repeat.as(:quoted_string) >>
          str(quote)
        end.reduce {|union, atom| union | atom }
      end
      rule(:multiline_string) { multiline_string_rule(:multiline_string) }
      
      def multiline_string_rule(capture_name=nil)
        scope do
          content = (multiline_string_end_delimeter.absent? >> any).repeat
          content = content.as(capture_name) if capture_name
          
          str('[') >> str('=').repeat.capture(:multiline_equal_padding) >> str('[') >> str("\n").maybe >>
          content >>
          multiline_string_end_delimeter
        end
      end
      
      rule :multiline_string_end_delimeter do
        str(']') >> dynamic {|s, context| str(context.captures[:multiline_equal_padding]) } >> str(']')
      end
      
      
      # TODO add transformation for escape sequences
      rule(:escape_sequence) { char_escape | decimal_escape | hex_escape }
      rule(:char_escape) { str('\\') >> (match['abfnrtv"\'\\\\'] | str("\n") | str('\r').maybe >> str('\n')) }
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
      
      rule(:value_keyword) do
        [ :true, :false, :nil ].map {|sym| str(sym.to_s).as(sym) }.reduce {|union, atom| union | atom }
      end
      
      rule(:name) { match['a-zA-Z_'] >> match['a-zA-Z0-9_'].repeat }
      
      rule(:space) { (comment | match('\s')).repeat(1) }
      rule(:space?) { space.maybe }
      rule(:line_ending) { str("\r\n") | match["\r\n"] | any.absent? }
      
      rule(:comment) { long_comment | short_comment }
      rule(:long_comment) { str('--') >> multiline_string_rule }
      rule(:short_comment) do
        str('--') >> (line_ending.absent? >> any).repeat >> line_ending
      end
      
      root :document
      
    end
  end
end
