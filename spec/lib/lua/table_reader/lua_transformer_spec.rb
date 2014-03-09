require 'spec_helper'


describe Lua::TableReader::LuaTransformer do
  let(:parser) { Lua::TableReader::LuaParser.new }
  subject(:transformer) { Lua::TableReader::LuaTransformer.new }
  
  context 'when applied to parsed tables' do
    let(:parser_rule) { parser.table }
    
    it 'transforms empty tables' do
      parsed = parser_rule.parse('{ }')
      expect(transformer.apply(parsed)).to eq({})
    end
    
    context 'with only key-value pairs' do
      it 'transforms a simple table' do
        parsed = parser_rule.parse((<<-EOS).strip)
          {
            ["foo"] = "bar",
            ["a"] = "b",
          }
        EOS
        expect(transformer.apply(parsed)).to eq({ 'foo' => 'bar', 'a' => 'b' })
      end
      it 'transforms a table with nested tables' do
        parsed = parser_rule.parse((<<-EOS).strip)
          {
            ["foo"] = "bar",
            ["a"] = {
              ["1"] = "one",
              ["2"] = "two"
            },
          }
        EOS
        expect(transformer.apply(parsed)).to eq({
          'foo' => 'bar',
          'a' => {
            '1' => 'one',
            '2' => 'two'
          }
        })
      end
      # TODO
    end
    
    # TODO other types
  end
  
  # TODO
end
