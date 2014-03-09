require 'parslet'

module Lua
  module TableReader
    class LuaTransformer < Parslet::Transform
      
      rule(string: simple(:str)) { str.to_s }
      
      TableEntry = Struct.new(:key, :value)
      
      rule(key: simple(:key), value: subtree(:value)) { TableEntry.new(key, value) }
      rule(str_key: simple(:key), value: subtree(:value)) { TableEntry.new(key.to_s, value) }
      
      rule(table: subtree(:table)) do
        entries = table.is_a?(Array) ? table : [ table ].compact
        entries.reduce({}) do |hash, entry|
          hash[entry.key] = entry.value
          hash
        end
      end
      
      # TODO
    end
  end
end
