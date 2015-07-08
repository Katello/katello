/**
 * @ngdoc object
 * @name  Bastion.repositories.controller:RepositoryManageContentController
 *
 * @requires $scope
 * @requires translate
 * @requires Repository
 *
 * @description
 *   Provides the functionality for the repository details pane.
 */
angular.module('Bastion.repositories').controller('RepositoryManageOstreeBranchesController',
    ['$scope', 'translate', 'Repository',
    function ($scope, translate, Repository) {

        function resetBranches() {
            $scope.branch = {
                editMode: false,
                working: false
            };
        }

        function saveBranches(branches, success, errors) {
            var successfulUpdate, erroredUpdate;
            successfulUpdate = function (repository) {
                $scope.successMessages = [translate('Repository Branches Updated.')];
                $scope.wrap(repository);
                if (success) {
                    success(repository);
                }
            };

            erroredUpdate = function (response) {
                _.each(response.data.errors, function (errorMessage) {
                    $scope.errorMessages.push(translate("An error occurred saving the Repository: ") + errorMessage);
                });
                if (errors) {
                    errors(response);
                }
            };

            $scope.repository["ostree_branches"] = branches;
            $scope.repository.$update(successfulUpdate, erroredUpdate);
        }

        $scope.wrap = function (repository) {
            var branches = repository["ostree_branches"];
            if (angular.isUndefined(branches)) {
                branches = [];
            }
            $scope.branchObjects = _.map(branches, function (branch) {
                return {name: branch};
            });
        };

        resetBranches();
        $scope.repository = Repository.get({id: $scope.$stateParams.repositoryId});

        $scope.repository.$promise.then($scope.wrap);

        $scope.removeBranches = function () {
            var branches,
                branchObjectsToRemove = _.reject($scope.branchObjects, function (branch) {
                return branch.selected;
            });

            branches = _.map(branchObjectsToRemove, function (branchObj) {
                return branchObj.name;
            });

            saveBranches(branches);
        };

        $scope.backupPrevious = function (currentBranch) {
            currentBranch.previous = {};
            angular.copy(currentBranch, currentBranch.previous);
        };

        $scope.restorePrevious = function (currentBranch) {
            angular.copy(currentBranch.previous, currentBranch);
            currentBranch.previous = {};
        };

        $scope.isValid = function (currentBranch) {
            return !_.isEmpty(currentBranch.name);
        };

        $scope.addBranch = function (currentBranch) {
            var branches = [currentBranch.name], success, error;
            _.each($scope.branchObjects, function (branchObj) {
                branches.push(branchObj.name);
            });

            success = function () {
                resetBranches();
            };
            error = function () {
                resetBranches();
            };

            saveBranches(branches, success, error);
        };

        $scope.updateBranch = function (currentBranch) {
            var success,
                error,
                branches = _.map($scope.branchObjects, function (branchObj) {
                return branchObj.name;
            });

             // Need access to the original branch
            success = function () {
                currentBranch.previous = {};
                currentBranch.editMode = false;
                currentBranch.working = false;
            };

            error = function () {
                currentBranch.working = false;
            };

            saveBranches(branches, success, error);
        };

        $scope.getSelectedBranches = function () {
            return _.select($scope.branchObjects, function (branch) {
                return branch.selected;
            });
        };

        $scope.selectAll = function (val) {
            _.each($scope.branchObjects, function (branch) {
                branch.selected = val;
            });
        };
    }]
);
