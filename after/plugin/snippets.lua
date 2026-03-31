local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- Пример сниппета для расширения .lua
ls.add_snippets("lua", {
  s("hello", {
    t('print("Hello, '),
    i(1),
    t('")'),
  }),
})

-- Вы можете добавлять сниппеты для разных языков, указав первым аргументом строку с именем файлового типа (ft)
ls.add_snippets("python", {
  s("hello", {
    t('print("Hello, '),
    i(1),
    t('")'),
  }),
})

-- Также можно добавить глобальные сниппеты (для всех файловых типов)
ls.add_snippets("all", {
  s("date", {
    t(os.date("%Y-%m-%d")),
  }),
})

ls.add_snippets("all", {
  s("pre", {
    t("<pre>{JSON.stringify("),
    i(1),
    t(", null, 2)}</pre>"),
    i(0),
  }),
})

ls.add_snippets("all", {
  s("prev", {
    t("<pre>{{JSON.stringify("),
    i(1),
    t(", null, 2)}}</pre>"),
    i(0),
  }),
})
