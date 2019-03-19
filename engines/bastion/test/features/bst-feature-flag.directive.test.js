describe('Directive:bstFeatureFlag', function() {
    var element, scope;

    beforeEach(module('Bastion.features'));

    beforeEach(module(function ($provide) {
        $provide.value('FeatureSettings', {'custom_products': false});
    }));

    beforeEach(inject(function($injector) {
        var compile = $injector.get('$compile');

        element = angular.element('<div bst-feature-flag="custom_products"><button>New Product</button><span>Test</span></div>');
        scope = $injector.get('$rootScope').$new();

        compile(element)(scope);
        scope.$digest();
    }));

    it("should remove the element if the feature is disabled", function () {
        expect(element.find('button').length).toBe(0);
    });

});
