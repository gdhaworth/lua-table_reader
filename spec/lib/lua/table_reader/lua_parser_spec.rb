require 'spec_helper'


describe Lua::TableReader::LuaParser do
  subject(:parser) { Lua::TableReader::LuaParser.new }
  
  context 'when parsing tables' do
    let(:rule) { parser.table }
    
    it 'consumes empty tables' do
      rule.parse('{ }')
    end
    
    context 'with only key-value pairs' do
      it 'consumes simple tables' do
        sample = <<-EOS
          {
            ["foo"] = "bar baz",
            ["a"] = "b",
          }
        EOS
        rule.parse(sample.strip)
        sample = <<-EOS
          {
            ["foo"] = "bar baz",
            ["a"] = "b"
          }
        EOS
        rule.parse(sample.strip)
      end
      it 'consumes nested tables' do
        sample = <<-EOS
          {
            ["foo"] = {
              ["bar"] = "baz",
            },
          }
        EOS
        rule.parse(sample.strip)
      end
      it 'consumes a mix of key and value definitions' do
        sample = File.read(File.join(File.dirname(__FILE__), 'key-value_table.lua'))
        rule.parse(sample.strip)
      end
    end
    
    # Other types of table data is handled in lua_transformer_spec.rb
  end
  
  context 'when parsing strings' do
    let(:rule) { parser.string }
    
    context 'with double-quotes' do
      it 'consumes simple samples' do
        expect(rule.parse('"foo bar"')).to include(quoted_string: "foo bar")
        expect(rule.parse('"foo \'bar\' baz"')).to include(quoted_string: "foo 'bar' baz")
      end
      it 'consumes samples with escape sequences' do
        expect(rule.parse('"The cow says \\"Moo\\""')).to include(quoted_string: 'The cow says \\"Moo\\"')
      end
    end
    
    context 'with single-quotes' do
      it 'consumes simple samples' do
        expect(rule.parse("'Hello world!'")).to include(quoted_string: "Hello world!")
      end
      it 'consumes samples with escape sequences' do
        expect(rule.parse("'I\\\'ve got an escape sequence!'")).to include(quoted_string: "I\\\'ve got an escape sequence!")
        expect(rule.parse("'foo bar \\\'asdf\\\' baz?'")).to include(quoted_string: "foo bar \\\'asdf\\\' baz?")
      end
    end
    
    context 'with multi-line delimeters' do
      it 'consumes simple samples' do
        expect(rule.parse('[[A single-line multi-line!]]')).to include(multiline_string: 'A single-line multi-line!')
        sample = <<-EOS
[[This is a multi-line string that
actually takes up multiple lines!]]
EOS
        expect(rule.parse(sample.strip)).to include(
          multiline_string: "This is a multi-line string that\nactually takes up multiple lines!")
      end
      it 'consumes samples with padded \'=\'' do
        expect(rule.parse('[=[The cake is a lie.]=]')).to include(multiline_string: 'The cake is a lie.')
        expect(rule.parse('[===[sample text]===]')).to include(multiline_string: 'sample text')
        expect(rule.parse('[==[ a ]=] b ]==]')).to include(multiline_string: ' a ]=] b ')
        sample = <<-EOS
[=[Line 1
[[Line 2]]
Line 3]=]
EOS
        expect(rule.parse(sample.strip)).to include(multiline_string: "Line 1\n[[Line 2]]\nLine 3")
      end
    end
  end
end
