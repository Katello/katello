export const mapTables = (tables) => {
  const tableObject = {};
  tables.forEach((element) => {
    tableObject[element.name] = element;
  });
  return tableObject;
};
export default mapTables;
