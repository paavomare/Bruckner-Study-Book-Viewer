module.exports = {
  printWidth: 80,
  tabWidth: 2,
  overrides: [
    {
      files: '*.md',
      options: {
        tabWidth: 4,
      },
    },
  ],
  useTabs: false,
  semi: true,
  singleQuote: true,
  trailingComma: 'all',
  bracketSpacing: true,
  jsxBracketSameLine: false,
  arrowParens: 'avoid',
};
