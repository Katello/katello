/**
 * @ngdoc object
 * @name  Bastion.content-views.service:ContentViewRepositoriesService
 *
 * @requires translate
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').service('ContentViewRepositoriesUtil',
    ['translate', function (translate) {

        return function (scope) {

            function extractProducts(repositories) {
                var products = {};

                scope.product = {name: translate('All Products'), id: 'all'};

                angular.forEach(repositories, function (repository) {
                    products[repository.product.id] = repository.product;
                });

                products[scope.product.id] = scope.product;

                return products;
            }

            scope.product = {id: 'all'};
            scope.products = {};
            scope.filteredItems = [];

            scope.$watch('table.rows', function (repositories) {
                scope.products = extractProducts(repositories);
            });

            scope.repositoryFilter = function (repository) {
                var include = true;

                if (scope.product && scope.product.id !== 'all') {
                    if (repository.product.id !== scope.product.id) {
                        include = false;
                    }
                }

                return include;
            };

            scope.getSelected = function (nutupane) {
                var selected = nutupane.getAllSelectedResults().included.ids,
                    filtered = _.map(scope.filteredItems, 'id');

                selected = _.reject(selected, function (id) {
                    return !_.includes(filtered, id);
                });

                return selected;
            };

            scope.removeSelectedRepositoriesFromContentView = function (nutupane, contentView) {
                var ids = [],
                    selected = scope.getSelected(nutupane);

                angular.forEach(contentView['repository_ids'], function (id) {
                    if (selected.indexOf(id) === -1) {
                        ids.push(id);
                    }
                });

                contentView['repository_ids'] = ids;

                scope.save(contentView).then(function () {
                    nutupane.refresh();
                });
            };

            scope.addSelectedRepositoriesToContentView = function (nutupane, contentView) {
                var selected = scope.getSelected(nutupane);

                contentView['repository_ids'] = contentView['repository_ids'].concat(selected);

                scope.save(contentView).then(function () {
                    nutupane.refresh();
                });
            };
        };

    }]
);
