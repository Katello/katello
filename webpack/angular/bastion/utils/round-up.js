/**
 *  Converts an ng-model to a number.
 *   {{ 107.5 | roundUp }}
 */

export default function roundUp() {
    return function (value) {
        return Math.ceil(value);
    };
}