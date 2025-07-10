const selectTableSettings = (state, tableName) =>
  state.katello.settings?.tables[tableName] || undefined;

export default selectTableSettings;
