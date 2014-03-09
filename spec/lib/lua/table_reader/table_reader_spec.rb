require 'spec_helper'


# SAMPLE_TABLE_PATH = File.join(File.dirname(__FILE__), 'table.lua')

describe Lua::TableReader do
  context 'when reading the sample table' do
    # let!(:result) { subject.read_file(SAMPLE_TABLE_PATH) }
    
  	it 'should have the right values' do
      pending
      
      result.should respond_to(:SampleLuaTable)
      # result.SampleLuaTable.should_not be_nil
      # TODO
    end
    
    it 'should not have keys that do not exist'
  end
end
