$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ParserTest < Test::Unit::TestCase

  def test_parser_breaks_on_newlines
    lexer = Mustache::Parser.new
    tokens = lexer.compile "  Hi !\n  Ho !"
    assert_equal [:multi, [:static, "  Hi !\n"], [:static, "  Ho !"]], tokens
  end

  def test_parser_should_not_eat_whitespace_inside_section
    lexer = Mustache::Parser.new
    tokens = lexer.compile "( {{#section}}   \n   {{value}}   {{/section}} )"
    expected = [:multi, [:static, "( "], [:mustache, :section, "section",
      [:multi, [:static, "   "], [:mustache, :etag, "value"], [:static, "   "]]],
      [:static, " )"]]
    assert_equal expected, tokens
  end

  def test_parser_should_discard_indenting_whitespace_before_section
    lexer = Mustache::Parser.new
    tokens = lexer.compile "__\n  {{#section}}  {{value}}{{/section}}__"
    expected = [:multi, [:static, "__\n"], [:mustache, :section, "section",
      [:multi, [:static, "  "], [:mustache, :etag, "value"]]],
      [:static, "__"]]
    assert_equal expected, tokens
  end

  def test_parser_should_discard_indenting_whitespace_before_nested
    lexer = Mustache::Parser.new
    tokens = lexer.compile "__\n  {{#sx}}\n    {{#ns}}\n    {{value}}{{/ns}}{{/sx}}__"
    expected = [:multi, [:static, "__\n"], [:mustache, :section, "sx",
      [:multi, [:mustache, :section, "ns",
        [:multi, [:static, "    "], [:mustache, :etag, "value"]]]]],
      [:static, "__"]]
    assert_equal expected, tokens
  end

  def test_parser
    lexer = Mustache::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{header}}</h1>
{{#items}}
{{#first}}
<li><strong>{{name}}</strong></li>
{{/first}}
{{#link}}
<li><a href="{{url}}">{{name}}</a></li>
{{/link}}
{{/items}}
{{#empty}}
<p>The list is empty.</p>
{{/empty}}
EOF

    expected = [:multi,
      [:static, "<h1>"],
      [:mustache, :etag, "header"],
      [:static, "</h1>\n"],
      [:mustache,
        :section,
        "items",
        [:multi,
          [:mustache,
            :section,
            "first",
            [:multi,
              [:static, "<li><strong>"],
              [:mustache, :etag, "name"],
              [:static, "</strong></li>\n"]]],
          [:mustache,
            :section,
            "link",
            [:multi,
              [:static, "<li><a href=\""],
              [:mustache, :etag, "url"],
              [:static, "\">"],
              [:mustache, :etag, "name"],
              [:static, "</a></li>\n"]]]]],
      [:mustache,
        :section,
        "empty",
        [:multi, [:static, "<p>The list is empty.</p>\n"]]]]

    assert_equal expected, tokens
  end
end
