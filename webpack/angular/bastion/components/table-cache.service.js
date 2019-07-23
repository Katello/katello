function TableCache($cacheFactory) {
  var cache = $cacheFactory('bst-table');

  this.setTable = function (tableName, table) {
    cache.put(tableName, table);
  };

  this.removeTable = function (tableName) {
    cache.remove(tableName);
  };

  this.getTable = function (tableName) {
    return cache.get(tableName);
  };
}

TableCache.$inject = ['$cacheFactory'];

export default TableCache;
