export const selectSettings = state => state.katello.settings?.settings;

export const selectTableSettings = (state, tableName) =>
  state.katello.settings?.tables[tableName] || undefined;
