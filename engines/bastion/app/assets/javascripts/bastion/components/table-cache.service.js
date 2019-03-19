(function () {
    /**
     * @ngdoc service
     * @name Bastion.components:TableCache
     *
     * @description
     *   Used to save the table between states so that the search, etc. can be remembered
     *   upon revisiting the state.
     **/
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

    angular.module('Bastion.components').service('TableCache', TableCache);
    TableCache.$inject = ['$cacheFactory'];
})();
