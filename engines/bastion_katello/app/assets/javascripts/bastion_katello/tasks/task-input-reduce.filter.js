/**
 * @ngdoc filter
 * @name  Bastion.tasks.filter:taskInputReduce
 *
 * @description
 *   Omits the parts of task humanized input that are not necessary to
 *   show (such as repository name in tasks list or a repository)
 */
angular.module('Bastion.tasks')
    .filter('taskInputReduce', function () {
        return function (humanizedTaskInput, skippedParts) {
            if (_.isString(humanizedTaskInput) || !skippedParts) {
                return humanizedTaskInput;
            }
            if (_.isString(skippedParts)) {
                skippedParts = skippedParts.split(',');
            }
            return _.reject(humanizedTaskInput, function (part) {
                if (part.length === 2) {
                    return _.includes(skippedParts, part[0]);
                }

                return false;
            });
        };
    });
