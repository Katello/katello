/**
 * @ngdoc service
 * @name  Bastion.components.service:Notification
 *
 * @description
 *  Service to display a foreman toast notification
 */
angular.module('Bastion.components').service("Notification", ['$interpolate', 'foreman', function ($interpolate, foreman) {
    function interpolateIfNeeded(message, context) {
        var result = message;

        if (context) {
            result = $interpolate(message)(context);
        }

        return result;
    }

    this.setSuccessMessage = function (message, options) {
        var baseOptions, fullOptions;
        /* eslint-disable no-unused-expressions */
        (angular.isUndefined(options)) && (options = {});
        /* eslint-enable no-unused-expressions */
        baseOptions = { message: interpolateIfNeeded(message, options.context), type: 'success' };
        delete options.context;
        fullOptions = _.extend(baseOptions, options);
        foreman.toastNotifications.notify(fullOptions);
    };

    this.setWarningMessage = function (message, context) {
        foreman.toastNotifications.notify({message: interpolateIfNeeded(message, context), type: 'warning'});
    };

    this.setErrorMessage = function (message, context) {
        foreman.toastNotifications.notify({message: interpolateIfNeeded(message, context), type: 'danger'});
    };
}]);
