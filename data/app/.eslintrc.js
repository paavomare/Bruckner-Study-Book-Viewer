module.exports = {
  env: {
    browser: true,
    commonjs: true,
    es6: true,
    mocha: true,
    node: true,
  },
  globals: {
    expect: false,
  },
  extends: ['eslint:recommended', 'plugin:react/recommended'],
  parserOptions: {
    sourceType: 'module',
    ecmaVersion: 2018,
  },
  rules: {
    'linebreak-style': ['error', 'unix'],
    quotes: ['error', 'single'],
    semi: ['error', 'always'],
    'no-console': ['warn'],
    'max-len': ['warn', { ignoreComments: true }],
    'comma-dangle': ['error', 'always-multiline'],
    'no-unused-vars': [
      'error',
      { argsIgnorePattern: '^_+', varsIgnorePattern: '^_+' },
    ],
  },
};
