require 'parslet'

module Lua
  module TableReader
    class LuaTransformer < Parslet::Transform
      
      def self.build_escape_replacements
        escape_letters = %w{ a b f n r t v ' " }
        replacements = escape_letters.map {|letter| [ ('\\' + letter), eval("\"\\#{letter}\"") ].freeze }
        replacements << [ "\\\n", "\n" ]  # intentional, per Lua spec
        replacements << [ '\\\\', '\\' ]  # needs to go last
        replacements.freeze
      end
      
      ESCAPE_REPLACEMENTS = build_escape_replacements.freeze
      
      rule(quoted_string: simple(:str)) do
        ESCAPE_REPLACEMENTS.inject(str.to_s) {|result, replacement| result.gsub(*replacement) }
      end
      rule(multiline_string: simple(:str)) { str.to_s }
      
      rule(int: simple(:int)) { int.to_i }
      rule(float: simple(:float)) { float.to_f }
      rule(hex: simple(:hex)) { hex.to_s.hex }
      
      
      TableHashEntry = Struct.new(:key, :value)
      
      rule(key: simple(:key), value: subtree(:value)) { TableHashEntry.new(key, value) }
      rule(str_key: simple(:key), value: subtree(:value)) { TableHashEntry.new(key.to_s, value) }
      rule(value: subtree(:value)) { value }
      
      class TableBuilder
        def initialize
          @hash_entries = []
          @array_entries = []
        end
        
        def add(entry)
          (entry.is_a?(TableHashEntry) ? @hash_entries : @array_entries) << entry
        end
        
        def build
          if @hash_entries.empty?
            return @array_entries unless @array_entries.empty?
          end
          
          result = {}
          unless @array_entries.empty?
            @array_entries.each_with_index {|entry, index| result[index + 1] = entry }
          end
          @hash_entries.each do |table_hash_entry|
            # TODO handle overlapping array indices and hash keys
            result[table_hash_entry.key] = table_hash_entry.value
          end
          result
        end
      end
      
      rule(table: subtree(:table)) do
        entries = table.is_a?(Array) ? table : [ table ].compact
        
        builder = TableBuilder.new
        entries.each(&builder.method(:add))
        builder.build
      end
      
      # TODO
    end
  end
end
