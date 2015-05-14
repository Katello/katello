/**
 * @ngdoc filter
 * @name  Bastion.errata.filter:errataSeverity
 *
 * @requires translate
 *
 * @description
 *   A filter to turn am errata's severity into an easier to read, translated string.
 *
 * @example
 *   {{ 'moderate' | errataSeverity }} will produce the string "Moderate".
 */
angular.module('Bastion.errata').filter('errataSeverity', ['translate', function (translate) {
    return function (type) {
        var errataSeverity;

        switch (type) {
        case 'Moderate':
            errataSeverity = translate('Moderate');
            break;
        case 'Important':
            errataSeverity = translate('Important');
            break;
        case 'Critical':
            errataSeverity = translate('Critical');
            break;
        case '':
            errataSeverity = translate('N/A');
            break;
        default:
            errataSeverity = type;
        }

        return errataSeverity;
    };

}]);
