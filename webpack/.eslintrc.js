const path = require('path');
const { foremanLocation, foremanRelativePath } = require('@theforeman/find-foreman');
const foremanFull = foremanLocation();

module.exports = {
  env: {
    browser: true,
    'jest/globals': true
  },
  'extends': [
    'airbnb',
    'plugin:jest/recommended',
  ],
  plugins: [
    'jest',
    'react',
    'react-hooks',
    'promise',
    '@theforeman/rules'
  ],
  parser: '@babel/eslint-parser',
  rules: {
    // https://github.com/yannickcr/eslint-plugin-react/issues/1679 
    // TODO: Add this to foreman rules somewhere
    "indent": ["error", 2, {
      "ignoredNodes": ['JSX*', 'JSXElement', 'JSXElement > *', 'JSXAttribute', 'JSXIdentifier', 'JSXNamespacedName', 'JSXMemberExpression', 'JSXSpreadAttribute', 'JSXExpressionContainer', 'JSXOpeningElement', 'JSXClosingElement', 'JSXText', 'JSXEmptyExpression', 'JSXSpreadChild']
    }],
    'react/jsx-filename-extension': 'off',
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': ["warn", {
      "additionalHooks": "(useDeepCompareEffect)"
    }],
    // Import rules off for now due to HoundCI issue
    'import/no-unresolved': 'off',
    'import/extensions': 'off',
    'import/no-extraneous-dependencies': [
      "error",
      {
        // Need to check Katello, Foreman, and Foreman's meta package for dependencies
        "packageDir": [path.join(__dirname, '../../katello'), foremanFull]
      }
    ],
    'jsx-a11y/anchor-is-valid': [
      'error',
      {
        components: [
          'Link',
          'LinkContainer'
        ],
        specialLink: [
          'to'
        ]
      }
    ],
    'jsx-a11y/label-has-for': [
      'error',
      {
        'required': {
          // Some patternfly components don't play well with the 'nesting' check
          "every": ["id"]
        },
      }
    ],
    'promise/prefer-await-to-then': 'error',
    'promise/prefer-await-to-callbacks': 'error',
    'no-unused-vars': [
      'error',
      {
        vars: 'all',
        args: 'after-used',
        ignoreRestSiblings: true,
        argsIgnorePattern: '^_'
      }
    ],
    '@theforeman/rules/require-ouiaid': "error",
  }
}
