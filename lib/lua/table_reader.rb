require "lua/table_reader/version"
require "lua/table_reader/lua_parser"
require "lua/table_reader/lua_transformer"


module Lua
  module TableReader
    
    def self.read_file(path)
      contents = File.read(path)
      LuaTransformer.new.apply(LuaParser.new.parse(contents))
    end
    
  end
end
