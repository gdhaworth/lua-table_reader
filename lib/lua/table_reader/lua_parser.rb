require 'parslet'


module Lua
  module TableReader
    class LuaParser < Parslet::Parser
      
      rule :string do
        quoted_string | multiline_string
      end
      
      rule :quoted_string do
        %w{ ' " }.map do |quote|
          str(quote) >>
          (
            escape_sequence |
            (str('\\') | str(quote)).absent? >> any
          ).repeat.as(:string_content) >>
          str(quote)
        end.reduce {|union, atom| union | atom }
      end
      
      rule :multiline_string do
        str('[') >> str('=').repeat.capture(:multiline_equal_padding) >> str('[') >>
        (multiline_string_end_delimeter.absent? >> any).repeat.as(:string_content) >>
        multiline_string_end_delimeter
      end
      
      rule :multiline_string_end_delimeter do
        str(']') >> dynamic {|s, context| str(context.captures[:multiline_equal_padding]) } >> str(']')
      end
        
      
      rule(:escape_sequence) { char_escape | decimal_escape | hex_escape }
      rule(:char_escape) { str('\\') >> (match['abfnrtvz"\'\\\\'] | str('\r').maybe >> str('\n')) }
      rule(:decimal_escape) { str('\\') >> match['0-2'].maybe >> match('\d').repeat(1,2) }
      rule(:hex_escape) { str('\\x') >> match['0-9a-fA-F'].repeat(2,2) }
      
      
      rule(:space) { match('\s').repeat(1) }
      rule(:space?) { space.maybe }
      
      
      # TEMP
      root :string
      
    end
  end
end
