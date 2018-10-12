/**
 * @ngdoc filter
 * @name  Bastion.tasks.filter:taskInputCompile
 *
 * @description
 *   Produces the shortest possible version of humanized input of a
 *   task, used for list of recent user tasks.
 */

angular.module('Bastion.tasks')
    .filter('taskInputShort', function () {
        return function (humanizedTaskInput) {
            if (_.isString(humanizedTaskInput)) {
                return humanizedTaskInput;
            }
            return _.first(humanizedTaskInput, 1);
        };
    });
