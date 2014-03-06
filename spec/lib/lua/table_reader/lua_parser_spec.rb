require 'spec_helper'


describe Lua::TableReader::LuaParser do
  context 'when parsing' do
    let(:parser) { Lua::TableReader::LuaParser.new }
    
    context 'double-quoted strings' do
      it 'consumes simple samples'
      it 'consumes samples with escape sequences'
    end
    
    context 'single-quoted strings' do
      it 'consumes simple samples'
      it 'consumes samples with escape sequences'
    end
    
    context 'multi-line strings' do
      it 'consumes simple samples'
      it 'consumes samples with padded \'=\''
    end
  end
end
