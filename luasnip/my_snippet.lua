local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node
local i = ls.insert_node -- узел для вставки
local c = ls.choice_node

return s(
  "my", -- триггер
  {
    t({ "", "my_snippet_description" }), -- описание сниппета
    i(1), -- первый узел для вставки
    f(function()
      return os.date("%Y-%m-%d")
    end), -- узел с функцией
  }
)
