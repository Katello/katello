describe('Service: ApiErrorHandler', function() {
    var ApiErrorHandler, GlobalNotification;

    beforeEach(module('Bastion.common'));

    beforeEach(module(function($provide) {
        GlobalNotification = {
            setErrorMessage: function () {}
        };
        $provide.value('GlobalNotification', GlobalNotification);
    }));

    beforeEach(inject(function($injector) {
        ApiErrorHandler = $injector.get('ApiErrorHandler');
    }));

    describe("Provides a function to handle GET request errors", function() {
        var response = {};

        beforeEach(function () {
            spyOn(GlobalNotification, 'setErrorMessage');
        });

        it("uses the errors array if it exists in the response", function () {
            response = {
                data: {
                    errors: ['an error', 'another one']
                }
            };

            ApiErrorHandler.handleGETRequestErrors(response);
            expect(GlobalNotification.setErrorMessage).toHaveBeenCalledWith(response.data.errors[0]);
            expect(GlobalNotification.setErrorMessage).toHaveBeenCalledWith(response.data.errors[1]);
        });

        it("provides a generic message if the errors array does not exist in the response", function () {
            ApiErrorHandler.handleGETRequestErrors(response);
            expect(GlobalNotification.setErrorMessage).toHaveBeenCalledWith(jasmine.any(String));
        });

        it("sets a panel error boolean if $scope is provided", function () {
            var scope = {panel: {}};
            ApiErrorHandler.handleGETRequestErrors(response, scope);
            expect(scope.panel.error).toBe(true);
        });
    });
});
