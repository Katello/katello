// Helper for selectable rows, call with setRows hook for Table prop
const onSelect = setRows => (_event, isSelected, rowId) => {
  let rows;
  if (rowId === -1) {
    rows = rows.map(row => ({ ...row, selected: isSelected }));
  } else {
    rows = [...rows];
    rows[rowId].selected = isSelected;
  }

  setRows(rows);
};


export default onSelect;
