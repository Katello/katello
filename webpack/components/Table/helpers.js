// Can be included as a TableWrapper prop for selectable rows
const onSelect = (rows, setRows) => (_event, isSelected, rowId) => {
  let newRows;
  if (rowId === -1) {
    newRows = rows.map(row => ({ ...row, selected: isSelected }));
  } else {
    newRows = [...rows];
    newRows[rowId].selected = isSelected;
  }

  setRows(newRows);
};

export default onSelect;
