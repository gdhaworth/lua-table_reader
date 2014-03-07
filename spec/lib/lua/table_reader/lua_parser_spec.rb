require 'spec_helper'


describe Lua::TableReader::LuaParser do
  subject(:parser) { Lua::TableReader::LuaParser.new }
  
  context 'when parsing strings' do
    let(:rule) { parser.string }
    
    context 'with double-quotes' do
      it 'consumes simple samples' do
        expect(rule.parse('"foo bar"')).to include(content: "foo bar")
        expect(rule.parse('"foo \'bar\' baz"')).to include(content: "foo 'bar' baz")
      end
      it 'consumes samples with escape sequences' do
        expect(rule.parse('"The cow says \\"Moo\\""')).to include(content: 'The cow says \\"Moo\\"')
      end
    end
    
    context 'with single-quotes' do
      it 'consumes simple samples' do
        expect(rule.parse("'Hello world!'")).to include(content: "Hello world!")
      end
      it 'consumes samples with escape sequences' do
        expect(rule.parse("'I\\\'ve got an escape sequence!'")).to include(content: "I\\\'ve got an escape sequence!")
        expect(rule.parse("'foo bar \\\'asdf\\\' baz?'")).to include(content: "foo bar \\\'asdf\\\' baz?")
      end
    end
    
    context 'with multi-line delimeters' do
      it 'consumes simple samples' do
        expect(rule.parse('[[A single-line multi-line!]]')).to include(content: 'A single-line multi-line!')
        sample = <<-EOS
[[This is a multi-line string that
actually takes up multiple lines!]]
EOS
        expect(rule.parse(sample.strip)).to include(
          content: "This is a multi-line string that\nactually takes up multiple lines!")
      end
      it 'consumes samples with padded \'=\'' do
        expect(rule.parse('[=[The cake is a lie.]=]')).to include(content: 'The cake is a lie.')
        expect(rule.parse('[===[sample text]===]')).to include(content: 'sample text')
        expect(rule.parse('[==[ a ]=] b ]==]')).to include(content: ' a ]=] b ')
        sample = <<-EOS
[=[Line 1
[[Line 2]]
Line 3]=]
EOS
        expect(rule.parse(sample.strip)).to include(content: "Line 1\n[[Line 2]]\nLine 3")
      end
    end
  end
end
