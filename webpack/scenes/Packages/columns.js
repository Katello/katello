import React from "react"

const headerFormat = value => <th>{value}</th>;
const cellFormat = value => <td>{value}</td>;

const packagesColumns = [
  {header: {label: 'Name',formatters: [headerFormat]},cell: {formatters: [cellFormat]},property: 'name'},
  {header: {label: 'Version',formatters: [headerFormat]},cell: {formatters: [cellFormat]},property: 'version'},
];

export default packagesColumns;
