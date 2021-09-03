// Can be included as a TableWrapper prop for selectable rows
const onSelect = (rows, setRows) => (_event, isSelected, rowId) => {
  let newRows;
  if (rowId === -1) {
    newRows = rows.map(row => ({ ...row, selected: isSelected }));
  } else {
    newRows = [...rows];
    newRows[rowId] = { ...newRows[rowId], selected: isSelected };
  }

  setRows(newRows);
};

export default onSelect;

export const getPageStats = ({ total, page, perPage }) => {
  // logic adapted from patternfly so that we can know the number of items per page
  const lastPage = Math.ceil(total / perPage) ?? 0;
  const firstIndex = total <= 0 ? 0 : ((page - 1) * perPage) + 1;
  let lastIndex;
  if (total <= 0) {
    lastIndex = 0;
  } else {
    lastIndex = page === lastPage ? total : page * perPage;
  }
  const pageRowCount = (lastIndex - firstIndex) + 1;
  return {
    firstIndex, lastIndex, pageRowCount, lastPage,
  };
};
