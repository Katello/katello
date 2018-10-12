describe('Service: ApiErrorHandler', function() {
    var ApiErrorHandler, Notification;

    beforeEach(module('Bastion.common'));

    beforeEach(module(function($provide) {
        Notification = {
            setErrorMessage: function () {}
        };
        $provide.value('Notification', Notification);
    }));

    beforeEach(inject(function($injector) {
        ApiErrorHandler = $injector.get('ApiErrorHandler');
    }));

    describe("Provides a function to handle GET request errors", function() {
        var response = {};

        beforeEach(function () {
            spyOn(Notification, 'setErrorMessage');
        });

        it("uses the errors array if it exists in the response", function () {
            response = {
                data: {
                    errors: ['an error', 'another one']
                }
            };

            ApiErrorHandler.handleGETRequestErrors(response);
            expect(Notification.setErrorMessage).toHaveBeenCalledWith(response.data.errors[0]);
            expect(Notification.setErrorMessage).toHaveBeenCalledWith(response.data.errors[1]);
        });

        it("provides a generic message if the errors array does not exist in the response", function () {
            ApiErrorHandler.handleGETRequestErrors(response);
            expect(Notification.setErrorMessage).toHaveBeenCalledWith(jasmine.any(String));
        });

        it("sets a panel error boolean if $scope is provided", function () {
            var scope = {panel: {}};
            ApiErrorHandler.handleGETRequestErrors(response, scope);
            expect(scope.panel.error).toBe(true);
        });
    });

    describe("Provides a function to handle PUT request errors", function() {
        var response = {};

        beforeEach(function () {
            spyOn(Notification, 'setErrorMessage');
        });

        it("uses the errors array if it exists in the response", function () {
            response = {
                data: {
                    errors: ['an error', 'another one']
                }
            };

            ApiErrorHandler.handlePUTRequestErrors(response);
            expect(Notification.setErrorMessage).toHaveBeenCalledWith(response.data.errors[0]);
            expect(Notification.setErrorMessage).toHaveBeenCalledWith(response.data.errors[1]);
        });

        it("provides a generic message if the errors array does not exist in the response", function () {
            ApiErrorHandler.handlePUTRequestErrors(response);
            expect(Notification.setErrorMessage).toHaveBeenCalledWith(jasmine.any(String));
        });

        it("sets a panel error boolean if $scope is provided", function () {
            var scope = {panel: {}};
            ApiErrorHandler.handlePUTRequestErrors(response, scope);
            expect(scope.panel.error).toBe(true);
        });
    });
});
