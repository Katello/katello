describe('Controller: ContentHostProductsController', function () {
    var $scope,
        $controller,
        translate,
        HostSubscription,
        mockHost,
        mockContent,
        mockProductContent;

    beforeEach(module('Bastion.content-hosts',
                       'content-hosts/views/content-hosts.html'));

    beforeEach(module(function ($stateProvider) {
        $stateProvider.state('content-hosts.fake', {});
    }));

    beforeEach(inject(function (_$controller_, $rootScope, $state) {
        $controller = _$controller_;
        $scope = $rootScope.$new();

        translate = function (message) {
            return message;
        };

        mockHost = {
            "id": 1
        };

        mockContent = {
            "label": "content_label"
        };

        mockProductContent = {
            "results": [{
                "enabled": 0,
                "enabled_override": "default",
                "product": {
                    "name": 'product_name'
                },
                "content": mockContent
            }]
        };


        HostSubscription = {
            productContent: function (params, callback) {
                callback(mockProductContent);
                return mockProductContent;
            },
            contentOverride: function(params, callback) {
                callback(mockProductContent);
            }
        };

        spyOn(HostSubscription, 'productContent').andCallThrough();
        spyOn(HostSubscription, 'contentOverride');

        $scope.host = mockHost;

        $controller('ContentHostProductsController', {
            $scope: $scope,
            translate: translate,
            HostSubscription: HostSubscription
        });
    }));

    it('gets the content host products', function () {
        expect(HostSubscription.productContent).toHaveBeenCalled();
        expect($scope.displayArea.isAvailableContent).toBe(true);
        expect($scope.displayArea.working).toBe(false);
    });

    it('should initialize product content successfully', function () {
        var newObject = $scope.products.product_name;
        expect(newObject[0].content).toBe(mockProductContent.results[0].content);
    });

    it('should calculate get enabled properly', function () {
        expect($scope.getEnabledText(0, 'default')).toBe("No (Default)");
        expect($scope.getEnabledText(1, 'default')).toBe("Yes (Default)");
        expect($scope.getEnabledText(0, 1)).toBe("Override to Yes");
        expect($scope.getEnabledText(0, "1")).toBe("Override to Yes");
        expect($scope.getEnabledText(1, "0")).toBe("Override to No");
    });

    it('should save overrides', function () {
        $scope.saveContentOverride(mockProductContent['results'][0])

        expect(HostSubscription.contentOverride).toHaveBeenCalledWith({id: mockHost.id}, {
            content_label: mockContent.label,
            name: 'enabled',
            value: 'default'
        }, jasmine.any(Function), jasmine.any(Function));
    });
});
