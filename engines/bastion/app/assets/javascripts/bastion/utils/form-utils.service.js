/**
 * @ngdoc service
 * @name Bastion.service.directive:FormUtils
 *
 * @requires uuid4
 *
 * @description
 *   A set of utilities that are useful when using forms.
 */
angular.module('Bastion.utils').service('FormUtils', ['uuid4', function (uuid4) {
    var regex = new RegExp("[^a-z0-9\\-_]+", 'gi'),
        replacement = "_",
        isASCII;

    /**
     * @ngdoc function
     * @name Bastion.service.FormUtils#labelize
     * @methodOf Bastion.service.FormUtils
     * @function
     *
     * @description
     *   Turns a resource's name attribute into a labelized value.
     *
     * @param {Resource} resource An object representing a resource entity with a name property
     * @returns {Bastion.service.FormUtils} Self for chaining.
     */
    this.labelize = function (resource) {
        if (resource.name) {
            resource.label = (isASCII(resource.name) && resource.name.length <= 128) ?
                resource.name.replace(regex, replacement) : uuid4.generate();
        }

        return this;
    };

    isASCII = function isASCII(str) {
        return (/^[\x00-\x7F]*$/).test(str);
    };

}]);
