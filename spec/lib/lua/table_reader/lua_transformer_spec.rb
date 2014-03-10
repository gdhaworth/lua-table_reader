require 'spec_helper'


describe Lua::TableReader::LuaTransformer do
  let(:parser) { Lua::TableReader::LuaParser.new }
  subject(:transformer) { Lua::TableReader::LuaTransformer.new }
  
  def expect_parsed_transformed(str)
    parsed = parser_rule.parse(str.strip)
    expect(transformer.apply(parsed))
  end
  
  context 'when applied to parsed tables' do
    let(:parser_rule) { parser.table }
    
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
    
    context 'with only array values' do
      it 'transforms a simple table into an array' do
        sample = <<-EOS
          {
            "foo", "bar", "baz"
          }
        EOS
        expect_parsed_transformed(sample).to eq(%w{ foo bar baz })
      end
      it 'transforms a table with a nested key-value table' do
        sample = <<-EOS
          {
            { foo = "bar" },
            "baz"
          }
        EOS
        expect_parsed_transformed(sample).to eq([ { 'foo' => 'bar' }, 'baz' ])
      end
    end
    
    context 'with both key-value pairs and array values' do
      it 'transforms a simple table into a hash' do
        sample = <<-EOS
          {
            ["foo"] = "bar",
            "baz"
          }
        EOS
        expect_parsed_transformed(sample).to eq({ 'foo' => 'bar', 1 => 'baz' })
      end
      it 'transforms a table with nested tables' do
        sample = <<-EOS
          {
            'foo',
            'bar',
            table = {
              ["1"] = "one"
            },
            'baz'
          }
        EOS
        expect_parsed_transformed(sample).to eq({
          'table' => {
            '1' => 'one'
          },
          1 => 'foo',
          2 => 'bar',
          3 => 'baz'
        })
      end
    end
  end
  
  context 'when applied to parsed numbers' do
    let(:parser_rule) { parser.number }
    
    it 'transforms integers' do
      expect_parsed_transformed('42').to eq(42)
    end
    it 'transforms negative integers' do
      expect_parsed_transformed('-15').to eq(-15)
    end
    it 'transforms simple floats' do
      expect_parsed_transformed('3.14159').to eq(3.14159)
    end
    it 'transforms negative floats' do
      expect_parsed_transformed('-2.71828').to eq(-2.71828)
    end
    it 'transforms floats with an exponent' do
      expect_parsed_transformed('6.0221413e23').to eq(6.0221413e+23)
    end
    it 'transforms floats with an exponent and no decimal' do
      expect_parsed_transformed('.5446170e-3').to eq(5.446170e-4)
    end
    it 'transforms hex integers' do
      expect_parsed_transformed('0x2a').to eq(42)
    end
    it 'transforms negative hex integers' do
      expect_parsed_transformed('-0xdeadbeef').to eq(-3735928559)
    end
  end
  
  # TODO
end
