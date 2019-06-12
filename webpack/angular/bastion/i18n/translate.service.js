/**
 *   Provides a wrapper for gettextCatalog.getString().
 */
import 'angular-gettext';

export default ['gettextCatalog', function (gettextCatalog) {
    return function (str) {
        return gettextCatalog.getString(str);
    };
}];
