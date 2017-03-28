describe('Service: ContentOverrideHelper', function() {
    var ContentOverrideHelper;

    beforeEach(module('Bastion.repository-sets'));

    beforeEach(inject(function($injector) {
        ContentOverrideHelper = $injector.get('ContentOverrideHelper');
    }));

    it ("Provides the ability to construct content overrides", function () {
        var productRepositorySets, expectedResult;

        productRepositorySets = [
            {
                content: {
                    label: 'lalala'
                }
            }
        ];

        expectedResult = {
            'content_overrides': [
                {
                    'content_label': productRepositorySets[0].content.label,
                    name: 'name',
                    value: 1
                }
            ]
        };

        expect(ContentOverrideHelper.getContentOverrides(productRepositorySets, 'name', 1)).toEqual(expectedResult);
    });

    describe("Provides convenience methods", function() {
        var overrides = [1, 2, 3];

        beforeEach(function () {
            spyOn(ContentOverrideHelper, 'getContentOverrides');
        });

        it("for overriding to enabled", function () {
            ContentOverrideHelper.getEnabledContentOverrides(overrides);
            expect(ContentOverrideHelper.getContentOverrides).toHaveBeenCalledWith(overrides, 'enabled', true);
        });

        it("for overriding to disabled", function () {
            ContentOverrideHelper.getDisabledContentOverrides(overrides);
            expect(ContentOverrideHelper.getContentOverrides).toHaveBeenCalledWith(overrides, 'enabled', false);
        });

        it("for reseting to default", function () {
            ContentOverrideHelper.getDefaultContentOverrides(overrides);
            expect(ContentOverrideHelper.getContentOverrides).toHaveBeenCalledWith(overrides, 'enabled', false, true);
        });
    });
});
