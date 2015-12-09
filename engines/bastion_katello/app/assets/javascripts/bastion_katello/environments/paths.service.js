angular.module('Bastion.environments').service('PathsService',
    ['$q', 'Organization', 'CurrentOrganization',
        function ($q, Organization, CurrentOrganization) {

            this.getActualPaths = function () {
                var actualPaths = [];

                return this.loadPaths().then(function (paths) {
                    var data = {};
                    data.library = paths[0].environments[0];

                    angular.forEach(paths, function (path, index) {
                        paths[index].environments.splice(0, 1);

                        if (paths[index].environments.length !== 0) {
                            actualPaths.push(path);
                        }
                    });
                    data.paths = actualPaths;
                    return data;
                });
            };

            this.loadPaths = function () {
                var deferred = $q.defer();

                Organization.paths({id: CurrentOrganization}, function (response) {
                    deferred.resolve(response);
                });
                return deferred.promise;
            };

            this.getCurrentPath = function (prior) {
                return this.loadPaths().then(function (paths) {
                    var currentPath = null;
                    if (prior.library) {
                        currentPath = [prior];
                    } else {
                        angular.forEach(paths, function (path) {
                            angular.forEach(path.environments, function (env) {
                                if (env.id === prior.id) {
                                    currentPath = path;
                                }
                            });
                        });
                    }
                    return currentPath.environments;
                });
            };
        }]
);
