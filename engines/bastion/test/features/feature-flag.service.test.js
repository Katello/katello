describe('Service:FeatureFlag', function() {
    var FeatureFlag;

    beforeEach(module('Bastion.features'));

    beforeEach(module(function ($provide) {
        $provide.value('FeatureSettings', {'custom_products': false});
    }));

    beforeEach(inject(function($injector) {
        FeatureFlag = $injector.get('FeatureFlag');
        FeatureFlag.addStates('custom_products', ['products', 'products.new']);
    }));

    it("should allow checking if a feature is enabled", function () {
        expect(FeatureFlag.featureEnabled('custom_products')).toBe(false);
    });

    it("should default to true if a feature is undefined", function () {
        expect(FeatureFlag.featureEnabled('fake_flag')).toBe(true);
    });

    it("should allow checking if a state is enabled", function () {
        expect(FeatureFlag.stateEnabled('products')).toBe(false);
        expect(FeatureFlag.stateEnabled('products.fake')).toBe(true);
    });

    it("should allow adding states to a feature", function () {
        expect(FeatureFlag.addStates('custom_products', ['products.new.form'])).toBe(FeatureFlag);
        expect(FeatureFlag.stateEnabled('products.new.form')).toBe(false);
    });
});
