require "lua/table_reader/version"
require "lua/table_reader/lua_parser"


module Lua
  module TableReader
    
    def self.read_file(path)
      contents = File.read(path)
      # TODO
    end
    
    class Document
      def initialize(parse_matches)
        # TODO
      end
    end
    
  end
end
