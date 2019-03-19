/**
 * @ngdoc service
 * @name  Bastion.components.service:PageTitle
 *
 * @requires $window
 * @requires $interpolate
 *
 * @description
 *  Service to set the title of the page and maintain a
 */
angular.module('Bastion.components').service('PageTitle', ['$window', '$interpolate',
    function ($window, $interpolate) {
        this.titles = [];

        this.setTitle = function (title, locals) {
            var interpolated;

            if (title) {
                interpolated = $interpolate(title);

                $window.document.title = interpolated(locals);
                this.titles.push($window.document.title);
            }
        };

        this.resetToFirst = function () {
            this.titles = this.titles.slice(0, 1);
            $window.document.title = this.titles[0];
        };
    }]
);
