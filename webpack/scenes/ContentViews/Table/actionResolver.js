const actionResolver = (rowData, { _rowIndex }) => {
  // don't show actions for the expanded parts
  if (rowData.parent || rowData.compoundParent || rowData.noactions) return null;

  // printing to the console for now until these are hooked up
  /* eslint-disable no-console */
  return [
    {
      title: 'Publish and Promote',
      onClick: (_event, rowId, _rowInfo) => console.log(`clicked on row ${rowId}`),
    },
    {
      title: 'Promote',
      onClick: (_event, rowId, _rowInfo) => console.log(`clicked on row ${rowId}`),
    },
    {
      title: 'Copy',
      onClick: (_event, rowId, _rowInfo) => console.log(`clicked on row ${rowId}`),
    },
    {
      title: 'Delete',
      onClick: (_event, rowId, _rowInfo) => console.log(`clicked on row ${rowId}`),
    },
  ];
  /* eslint-enable no-console */
};

export default actionResolver;
