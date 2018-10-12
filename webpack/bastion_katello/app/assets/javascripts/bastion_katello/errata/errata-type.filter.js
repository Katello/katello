/**
 * @ngdoc filter
 * @name  Bastion.errata.filter:errataType
 *
 * @requires translate
 *
 * @description
 *   A filter to turn an errata type into an easier to read, translated string.
 *
 * @example
 *   {{ 'bugfix' | errataType }} will produce the translated string "Bug Fix Advisory".
 */
angular.module('Bastion.errata').filter('errataType', ['translate', function (translate) {
    return function (type) {
        var errataType;

        switch (type) {
        case 'bugfix':
            errataType = translate('Bug Fix Advisory');
            break;
        case 'enhancement':
            errataType = translate('Product Enhancement Advisory');
            break;
        case 'security':
            errataType = translate('Security Advisory');
            break;
        default:
            errataType = type;
        }

        return errataType;
    };

}]);
