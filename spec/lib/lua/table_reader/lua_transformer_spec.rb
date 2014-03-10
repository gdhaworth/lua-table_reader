require 'spec_helper'


describe Lua::TableReader::LuaTransformer do
  let(:parser) { Lua::TableReader::LuaParser.new }
  subject(:transformer) { Lua::TableReader::LuaTransformer.new }
  
  context 'when applied to parsed tables' do
    let(:parser_rule) { parser.table }
    
    def expect_parsed_transformed(str)
      parsed = parser_rule.parse(str.strip)
      expect(transformer.apply(parsed))
    end
    
    it 'transforms empty tables' do
      expect_parsed_transformed('{ }').to eq({})
    end
    
    context 'with only key-value pairs' do
      it 'transforms a simple table' do
        sample = <<-EOS
          {
            ["foo"] = "bar",
            ["a"] = "b",
          }
        EOS
        expect_parsed_transformed(sample).to eq({ 'foo' => 'bar', 'a' => 'b' })
      end
      it 'transforms a table with nested tables' do
        sample = <<-EOS
          {
            ["foo"] = "bar",
            ["a"] = {
              ["1"] = "one",
              ["2"] = "two"
            },
          }
        EOS
        expect_parsed_transformed(sample).to eq({
          'foo' => 'bar',
          'a' => {
            '1' => 'one',
            '2' => 'two'
          }
        })
      end
    end
    
    # TODO other types
  end
  
  # TODO
end
