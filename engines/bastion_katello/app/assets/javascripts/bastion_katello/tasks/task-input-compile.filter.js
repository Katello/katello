/**
 * @ngdoc filter
 * @name  Bastion.tasks.filter:taskInputCompile
 *
 * @description
 *   Converts the task humanized structure into a flat string
 */
angular.module('Bastion.tasks')
    .filter('taskInputCompile', function () {
        return function (humanizedTaskInput) {
            var parts;

            if (!_.isArray(humanizedTaskInput) && !_.isObject(humanizedTaskInput)) {
                return humanizedTaskInput;
            }

            parts = _.map(humanizedTaskInput, function (part) {
                if (part.length === 2) {
                    return part[1].text;
                }

                return part;
            });

            return parts.join('; ');
        };
    });
