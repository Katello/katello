//Katello global object namespace that all others should be attached to
var KT = KT ? KT : {};

//i18n global variable
var katelloI18n = {};

//Setup lodash
KT.utils = _.noConflict();

_ = KT.utils;

function localize(data) {
    for (var key in data) {
        if(data.hasOwnProperty(key)) {
            katelloI18n[key] = data[key];
        }
    }
}
