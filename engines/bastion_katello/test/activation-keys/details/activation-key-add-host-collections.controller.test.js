describe('Controller: ActivationKeyAddHostCollectionsController', function() {
    var $scope,
        ActivationKey,
        Nutupane,
        host_collections;

    beforeEach(module('Bastion.activation-keys', 'Bastion.host-collections', 'Bastion.test-mocks',
                      'activation-keys/details/views/activation-key-host-collections.html'));

    beforeEach(function() {
        Nutupane = function() {
            this.table = {
                showColumns: function() {}
            };
            this.get = function() {};
        };
        ActivationKey = {};
    });

    beforeEach(inject(function($controller, $rootScope, $location, $state, $injector) {
        $scope = $rootScope.$new();
        $q = $injector.get('$q');

        host_collections = {
            "total": 1,
            "subtotal": 1,
            "page": 1,
            "per_page": 20,
            "search": null,
            "sort": {
                "by": null,
                "order": null
            },
            "results": [
                {
                    "created_at": "2014-02-17T16:02:24Z",
                    "updated_at": "2014-02-17T16:02:24Z",
                    "name": "Employee",
                    "organization_id": 3,
                    "max_hosts": -1,
                    "description": null,
                    "total_content_hosts": 0,
                    "id": 14,
                    "permissions": {
                        "deletable": true,
                        "editable": true
                    }
                }
            ]
        };

        $controller('ActivationKeyAddHostCollectionsController', {
            $scope: $scope,
            $q: $q,
            $location: $location,
            translate: function() {},
            ActivationKey: ActivationKey,
            Nutupane: Nutupane
        });
    }));

    it('attaches the nutupane table to the scope', function () {
        expect($scope.table).toBeDefined();
    });

});
