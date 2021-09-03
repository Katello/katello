import { translate as __ } from 'foremanReact/common/I18n';

export default () => [
  {
    names: { title: __('Python Packages'), plural: 'python_packages', singular: 'python_package' },
    columnHeaders: [
      { title: __('Name'), getProperty: unit => unit?.name },
      { title: __('Version'), getProperty: unit => unit?.version },
    ],
  },
];
