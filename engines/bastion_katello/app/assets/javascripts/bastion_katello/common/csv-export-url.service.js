/**
 * @ngdoc service
 * @name  Bastion.common.service:CsvExportUrl
 *
 * @description
 *   Helper service that contains functionality common amongst csv urls
 */
angular.module('Bastion.common').service('CsvExportUrl', ['$location', '$httpParamSerializer',
    function ($location, $httpParamSerializer) {
        this.getCsvLink = function(params) {
        var tableName = $location.path().split('/').slice(1);
        return "/katello/api/v2/" + tableName + ".csv?" + $httpParamSerializer(params);
    };

    }

]);
