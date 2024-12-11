/**
 * @ngdoc controller
 * @name  Bastion.debs.controller:DebsController
 *
 * @description
 *   Handles fetching deb packages and populating Nutupane based on the current
 *   ui-router state.
 *
 * @requires translate
 *
 */
angular.module('Bastion.debs').controller('DebsController',
    ['$scope', '$location', 'translate', 'Nutupane', 'Deb', 'Repository', 'CurrentOrganization',
    function DebsController($scope, $location, translate, Nutupane, Deb, Repository, CurrentOrganization) {
        var nutupane;

        var params = {
            'organization_id': CurrentOrganization,
            'search': $location.search().search || "",
            'repository_id': $location.search().repositoryId || null,
            'paged': true,
            'sort_by': 'name',
            'sort_order': 'ASC'
        };

        nutupane = $scope.nutupane = new Nutupane(Deb, params);
        nutupane.primaryOnly = true;

        $scope.table = nutupane.table;

        // Labels so breadcrumb strings can be translated
        $scope.label = translate('Debs');
        $scope.repositoriesLabel = translate('Repositories');

        $scope.controllerName = 'katello_debs';

        $scope.repository = {name: translate('All Repositories'), id: 'all'};

        Repository.queryUnpaged({'organization_id': CurrentOrganization, 'content_type': 'deb', 'with_content': 'deb'}, function (response) {
            $scope.repositories = [$scope.repository];
            $scope.repositories = $scope.repositories.concat(response.results);

            if ($location.search().repositoryId) {
                $scope.repository = _.find($scope.repositories, function (repository) {
                    return repository.id === parseInt($location.search().repositoryId, 10);
                });
            }
        });

        Deb.queryPaged({'organization_id': CurrentOrganization}, function (result) {
            $scope.packageCount = result.total;
        });

        $scope.showApplicable = false;
        $scope.showUpgradable = false;

        $scope.toggleFilters = function () {
            if ($scope.showUpgradable === true) {
                $scope.showApplicable = true;
            }

            nutupane.table.params['packages_restrict_applicable'] = $scope.showApplicable;
            nutupane.table.params['packages_restrict_upgradable'] = $scope.showUpgradable;
            nutupane.refresh();
        };

        $scope.$watch('repository', function (repository) {
            var nutupaneParams = nutupane.getParams();

            if (repository.id === 'all') {
                nutupaneParams['repository_id'] = null;
                nutupane.setParams(nutupaneParams);
            } else {
                $location.search('repositoryId', repository.id);
                nutupaneParams['repository_id'] = repository.id;
                nutupane.setParams(nutupaneParams);
            }

            if (!nutupane.table.initialLoad) {
                nutupane.refresh();
            }
        });

    }]
);
