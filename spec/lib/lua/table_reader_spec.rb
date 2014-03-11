require 'spec_helper'


SAMPLE_TABLE_PATH = File.join(File.dirname(__FILE__), 'sample_table.lua')

describe Lua::TableReader do
  context 'when reading the sample table' do
  	it 'should have the right values' do
      expect(Lua::TableReader.read_file(SAMPLE_TABLE_PATH)).to eq({
        'foo' => 'simple string',
        'bar' => 'string with an "escape"',
        'baz' => 'one [[two]] one',
        'empty' => false,
        'to_english' => {
          1 => 'one',
          2 => 'two',
        }
      })
    end
  end
end
