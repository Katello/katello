/**
 * @ngdoc filter
 * @name  Bastion.subscriptions.filter:groupedFilter.filter.js
 *
 */
angular.module('Bastion.subscriptions').filter('groupedFilter', function () {
    return function (grouped, search) {
        var result = {};
        angular.forEach(grouped, function (value, key) {
            if (angular.isUndefined(search)) {
                search = "";
            } else {
                search = search.toLowerCase();
            }
            if (key.toLowerCase().indexOf(search) > -1 || search === "") {
                result[key] = value;
            }
        });
        return result;
    };
});
