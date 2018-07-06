import React from "react"

const headerFormat = value => <th>{value}</th>;
const cellFormat = value => <td>{value}</td>;

const packagesColumns = [
  {header: {label: 'First Name',formatters: [headerFormat]},cell: {formatters: [cellFormat]},property: 'first_name'},
  {header: {label: 'Last Name',formatters: [headerFormat]},cell: {formatters: [cellFormat]},property: 'last_name'},
  {header: {label: 'Username',formatters: [headerFormat]},cell: {formatters: [cellFormat]},property: 'username'},
];

export default packagesColumns;
