# TODO license info for https://github.com/antlr/grammars-v4/blob/master/lua/Lua.g4

require 'parslet'


module Lua
  module TableReader
    class LuaParser < Parslet::Parser
      
      rule :document do
        space? >> expression >> space?
      end
      
      rule :expression do
        string | table
        # TODO 'nil' | 'false' | 'true' | number | '...' | functiondef | prefixexp | exp binop exp | unop exp
      end
      
      
      rule :table do
        str('{') >> space? >> field_list.maybe.as(:table) >> str('}') >> space?
      end
      
      rule :field_list do
        field >> (field_separator >> field).repeat >> field_separator.maybe
      end
      
      rule :field do
        str('[') >> space? >> expression.as(:key) >> str(']') >> space? >> str('=') >> space? >> expression.as(:value) |
        name.as(:str_key) >> space? >> str('=') >> space? >> expression.as(:value) |
        expression.as(:value)
      end
      
      rule :field_separator do
        match[',;'] >> space?
      end
      
      
      rule :string do
        (quoted_string | multiline_string) >> space?
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
        
      
      rule(:escape_sequence) { char_escape | decimal_escape | hex_escape }
      rule(:char_escape) { str('\\') >> (match['abfnrtvz"\'\\\\'] | str('\r').maybe >> str('\n')) }
      rule(:decimal_escape) { str('\\') >> match['0-2'].maybe >> match('\d').repeat(1,2) }
      rule(:hex_escape) { str('\\x') >> match['0-9a-fA-F'].repeat(2,2) }
      
      
      rule(:name) { match['a-zA-Z_'] >> match['a-zA-Z0-9_'].repeat }
      
      rule(:space) { match('\s').repeat(1) }
      rule(:space?) { space.maybe }
      
      
      root :document
      
    end
  end
end
