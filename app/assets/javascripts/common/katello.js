/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/


/*
 * Katello Global JavaScript File
 * Author: @jrist
 * Date: 09/01/2010
 */


//Katello global object namespace that all others should be attached to
var KT = {};
KT.widget = {};

KT.utils = _.noConflict();

// load angular module to Katello
var Katello = angular.module('Katello', ['alchemy', 'alch-templates', 'ngSanitize']);

// Must be at the top to prevent AngularJS unnecessary digest operations
// And to handle the hashPrefix that AngularJS adds that confuses BBQ
$(window).bind("hashchange", function(event) {
// refresh the favicon to make sure it shows up
    $('link[type*=icon]').detach().appendTo('head');
});
$.bbq.pushState('!', '');

//i18n global variable
var i18n = {};

function localize(data) {
    for (var key in data) {
        i18n[key] =  data[key];
    }
}

function update_status() {
  var statusElement = $(".status");
  var i = setInterval(function() {
      $.ajax({
          url: "#{@_request.fullpath}",
          dataType: 'json',
          success: function (json, status, xhr) {
              statusElement.text(json.status);
              if (xhr.status == 200) clearInterval(i);
          },
          error: function (xhr, status, error) {
              statusElement.text(jQuery.parseJSON(xhr.responseText).message);
              clearInterval(i);
          }
      });
  }, 1000);
}

// Common functionality throughout Katello

// Simple function to dump a message to the browser error log
function log(msg) {
    setTimeout(function() {
        throw new Error(msg);
    }, 0);
}

// Workaround for a bug in chosen
// When a chosen select receives focus() invoked from js code
// it ends up in an infinite loop of displaying and hiding the options.
// 2pane gives automatically focus to a first enabled visible input on the panel.
// Therefore we disable the inner input at the beginning and enable it
// after 400ms.
//
// requires jQuery
$.fn.delayed_chosen = function(options, delay_time) {
    var chzn_input;

    $(this).chosen(options);

    delay_time = (delay_time === undefined) ? 400 : delay_time;
    chzn_input = $(this).parent().find('.chzn-container :input');
    chzn_input.prop('disabled', true);
    chzn_input.delay(delay_time).queue(function(){ $(this).prop('disabled', false); $(this).dequeue();} );
}

//requires jQuery
KT.getData = (function(fieldNames) {
    var data = {},
        value;

    $.each(fieldNames, function(i, fieldName){
        value = $('#'+fieldName).val();
        if (value !== undefined)
            data[fieldName] = value;
    });
    return data;
});


KT.helptip =  (function($) {
    var enable = function(key, url) {
        $.ajax({
          type: "POST",
          url: url,
          data: { "key":key},
          cache: false
          });
        },
        disable = function(key, url) {
          $.ajax({
            type: "POST",
            url: url,
            data: { "key":key},
            cache: false
           });
        },
        handle_close = function(){
          var key = this.id.split("helptip-opened_")[1],
              url = $(this).attr('data-url');

          $("#helptip-opened_" + key).hide();
          $("#helptip-closed_" + key).show();

          $(document).trigger('helptip-closed');

          disable(key, url);
        },
        handle_open = function(){
          var key = this.id.split("helptip-closed_")[1],
              url = $(this).attr('data-url');

          $("#helptip-opened_" + key).show();
          $("#helptip-closed_" + key).hide();

          $(document).trigger('helptip-opened');

          enable(key, url);
        };

    return {
        handle_close    :    handle_close,
        handle_open     :    handle_open
    };
})(jQuery);


//Add backwards compatible version of Object.keys
// https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Object/keys
if(!Object.keys) {
    Object.keys = function(o){
     if (o !== Object(o))
        throw new TypeError('Object.keys called on non-object');
     var ret=[],p;
     for(p in o) {
       if(Object.prototype.hasOwnProperty.call(o,p)){
         ret.push(p);
       }
     }
     return ret;
  };
}


//override the jQuery UJS $.rails.allowAction
$.rails.allowAction = function(element) {
    var message = element.data('confirm'),
    answer = false, callback;
    if (!message) { return true; }

    if ($.rails.fire(element, 'confirm')) {
        KT.common.customConfirm({
            message: message,
            yes_callback: function() {
                callback = $.rails.fire(element, 'confirm:complete', [answer]);
                if(callback) {
                    var oldAllowAction = $.rails.allowAction;
                    $.rails.allowAction = function() { return true; };
                    element.trigger('click');
                    $.rails.allowAction = oldAllowAction;
                }
            }
        });
    }
    return false;
};

//make jQuery Contains case insensitive
$.expr[':'].Contains = function(a, i, m) {
  return $(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};
$.expr[':'].contains = function(a, i, m) {
  return $(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};

//requires jQuery
KT.common = (function() {
    var root_url = undefined;
    return {
        height: function() {
            return $(window).height();
        },
        width: function() {
            return $(window).width();
        },
        scrollTop: function() {
            return $(window).scrollTop();
        },
        scrollLeft: function() {
            return $(window).scrollLeft();
        },
        decode: function(value){
            var decoded = decodeURIComponent(value);
            return decoded.replace(/\+/g, " ");
        },
        escapeId: function(myid) {
            return myid.replace(/([ #;&,.%+*~\':"!^$[\]()=>|\/])/g,'\\$1')
        },
        customConfirm : function (params) {
          var settings = {
              message: undefined,
              warning_message: undefined,
              yes_text: i18n.yes,
              no_text: i18n.no,
              yes_callback: function(){},
              no_callback: function(){},
              include_cancel: false
          },
          confirmTrue = new Boolean(true),
          confirmFalse = new Boolean(false);

          $.extend(settings, params);

          var message = "<div style='margin:20px;'><span class='status_confirm_icon'/><div style='margin-left: 24px; display:table;height:1%;'>" + settings.message + "</div></div>",
              warning_message = (settings.warning_message === undefined) ? undefined : "<div style='margin:20px;'><span class='status_warning_icon'/><div style='margin-left: 24px; display:table;height:1%;color:red;'>" + settings.warning_message + "</div></div>",
              html = (warning_message === undefined) ? message : "<div>"+message+warning_message+"</div>",
              buttons = {
                "Yes": {
                  click : function () {
                    $(this).dialog("close");
                    $(this).dialog("destroy");
                    settings.yes_callback();
                    return confirmTrue;
                  },
                  'class' : 'button',
                  'text' : settings.yes_text
                },
                "No": {
                  click:function () {
                    $(this).dialog("close");
                    $(this).dialog("destroy");
                    settings.no_callback();
                    return confirmFalse;
                  },
                  'class' : 'button',
                  'text' : settings.no_text
                }
              };

          if(settings.include_cancel === true) {
              buttons["Cancel"] = {
                click:function () {
                  $(this).dialog("close");
                  $(this).dialog("destroy");
                  return confirmFalse;
                },
                'class' : 'button',
                'text' : i18n.cancel
              };
          }

          $(html).dialog({
            closeOnEscape: true,
            open: function (event, ui) {
                $('.ui-dialog-titlebar-close').hide();
                $('.confirmation').find('.ui-button')[1].focus();
            },
            modal: true,
            resizable: false,
            width: 450,
            title: i18n.confirmation,
            dialogClass: "confirmation",
            buttons: buttons
          });
        },
        customAlert : function(message) {
          var html = "<div style='margin:20px;'><span class='status_exclamation_icon'/><div style='margin-left: 24px; display:table;height:1%;'>" + message + "</div></div>";
          $(html).dialog({
            closeOnEscape: true,
            open: function (event, ui) { $('.ui-dialog-titlebar-close').hide(); },
            modal: true,
            resizable: false,
            width: 300,
            title: i18n.alert,
            dialogClass: "alert",
            stack: false,
            buttons: {
                "Ok": {
                  click : function () {
                    $(this).dialog("close");
                    $(this).dialog("destroy");
                    return false;
                  },
                  'class' : 'button',
                  'text' : i18n.ok
                }
            }
          });
        },
        orgSwitcherSetup : function() {
            //org switcher
            var button = $('#switcherButton');
            var container = $('#switcherContainer');
            var box = $('#switcherBox');
            var form = $('#switcherForm');
            var orgbox = $('#orgbox');
            var orgboxapi = null;
            button.removeAttr('href');
            button.click(function(switcher) {
                box.fadeToggle('fast');
                button.toggleClass('active');
                container.toggleClass('active');
                if(button.hasClass('active')){
                    if(!(box.hasClass('jspScrollable'))){
                      //the horizontalDragMaxWidth kills the horizontal scroll bar
                      // (on purpose, since we have ellipsis...)
                      orgbox.jScrollPane({ hideFocus: true, horizontalDragMaxWidth: 0 });
                      orgbox.bind('jsp-initialised', function(event, isScrollable) {
                          $('#orgfilter_input').focus();
                        }
                      );
                      orgboxapi = orgbox.data('jsp');
                    }
                    $.ajax({
                        type: "GET",
                        url: orgbox.attr("data-url"),
                        cache: false,
                        success: function(data) {
                          orgboxapi.getContentPane().html(data);
                          orgboxapi.reinitialise();
                        },
                        error: function(data) {
                          orgboxapi.getContentPane().html('<div class="spinner" style="margin-top:3px"></div>');
                          orgboxapi.reinitialise();
                        },
                        complete: function() {
                          orgbox.trigger('jsp-initialised');
                        }
                    });
                }
            });
            form.mouseup(function() {
                return false;
            });
            $(document).mouseup(function(switcher) {
                if(!($(switcher.target).parents('#switcherContainer').length > 0)) {
                    button.removeClass('active');
                    container.removeClass('active');
                    box.fadeOut('fast');
                }
            });
            if ($('#switcherContainer').length >0){
              $('#orgbox a').live('click', function(){
                 $(document).mouseup();
                 $('#switcherContainer').html('<div class="spinner" style="margin-top:3px"></div>');
              });
            }
            $('.favorite').live('click', function(e) {
                KT.orgswitcher.checkboxChanged($(this).parent().find('.default_org'));
            });
        },
        orgBoxRefresh : function (){
          var orgbox = $('#orgbox');
          var orgboxapi = orgbox.data('jsp');
          orgboxapi.reinitialise();
        },
        orgFilterSetup : function(){
            $('form.filter').submit(function(){
                $('#orgfilter_input').change();
                return false;
            });
            $('#orgfilter_input').live('change, keyup', function(){
                if ($.trim($(this).val()).length >= 2) {
                    $("#orgbox .row:not(:contains('" + $(this).val() + "'))").filter(':not').fadeOut('fast');
                    $("#orgbox .row:contains('" + $(this).val() + "')").filter(':hidden').fadeIn('fast');
                } else {
                    $("#orgbox .row").fadeIn('fast');
                }
            });
            $('#orgfilter_input').val("").change();
        },
        rootURL : function() {
            if (root_url === undefined) {
                //root_url = $('#root_url').attr('data-url');
                root_url = KT.config['root_url'];
            }
            return root_url;
        },
        getSearchParams : function(val) {
            var search_string = $.bbq.getState('list_search');

            if( search_string ){
                return { 'search' : search_string };
            } else {
                return false;
            }
        },
        spinner_path : function() {
          return KT.common.rootURL() + "assets/icons/spinner.gif";
        },
        jscroll_init: function(element) {
            element.jScrollPane({ hideFocus: true });
        },
        jscroll_resize: function(element) {
            element.resize(function(event){
                var element = $('.scroll-pane');
                if (element.length){
                    element.data('jsp').reinitialise();
                }
            });
        },
        to_human_readable_bytes : function(bytes) {
            var sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'],
                i;

            if (bytes == 0) {
                return '0';
            } else {
                i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
                return ((i == 0) ? (bytes / Math.pow(1024, i)) : (bytes / Math.pow(1024, i)).toFixed(1)) + ' ' + sizes[i];
            }
        },
        icon_hover_change : function(element, shade){
            var background_position,
                icon = element.find('i[data-change_on_hover="' + shade + '"]'),
                shade_position;

            if( icon.length > 0 ){
                background_position = icon.css('background-position');

                if( background_position !== undefined ){
                    background_position = background_position.split(" ");

                    shade_position = (background_position[1] === "0" || background_position[1] === "0px") ? ' -16px' : ' 0';
                    background_position = background_position[0] + shade_position;

                    icon.css({ 'background-position' : background_position });
                }
            }
        },
        link_hover_setup : function(shade){
            $('a').live('mouseenter',
                function(){ KT.common.icon_hover_change($(this), shade); }
            ).live('mouseleave',
                function(){ KT.common.icon_hover_change($(this), shade); }
            );
        }
    };
})(jQuery);

KT.orgswitcher = (function($) {
    var checkboxChanged = function(checkbox) {
      var this_checkbox = $(checkbox);
      this_checkbox.attr("disabled", "disabled");
      //var for all favorite icons to clear them
      var all_favorites = $('.favorite');
      //current favorite
      var this_favorite = this_checkbox.parent().find('.favorite');
      var this_spinner = this_checkbox.parent().find('.fav_spinner');
      var name = this_checkbox.attr("name");

      //extract the URL for the preference change
      var url = checkbox.data("url");

      var selected_org_id = this_checkbox.attr("value");
      var checked = this_checkbox.attr("checked");
      var options = {};

      if (checked){
        options = {user_id : $('#user_id').data("user_id")};
      } else {
        options = {org : selected_org_id, user_id : $('#user_id').data("user_id")};
      }

      //hide the favorite icon temporarily while the ajax operation occurs
      this_favorite.hide();

      //show the spinner while waiting
      this_spinner.removeClass('hidden').show();

      $.ajax({
          type: "PUT",
          url: url,
          data: options,
          cache: false,
          success: function(data, textStatus, jqXHR){
            //hide spinner
            this_spinner.addClass('hidden').hide();
            if(checked){
              this_checkbox.attr("checked", false);
              this_favorite.addClass("favorites_icon-grey");
              this_favorite.removeClass("favorites_icon-black");
              this_favorite.attr("title", i18n.make_default_org);
              if(this_favorite.parent().find('label').length){
                this_favorite.parent().find('label').html(i18n.make_default_org);
              }
            } else {
              this_checkbox.attr("checked", true);
              all_favorites.removeClass("favorites_icon-black");
              all_favorites.attr("title", i18n.make_default_org);
              $('.favorite').addClass("favorites_icon-grey");
              this_favorite.removeClass("favorites_icon-grey").addClass("favorites_icon-black");
              this_favorite.attr("title", i18n.current_default_org);
              if(this_favorite.parent().find('label').length){
                this_favorite.parent().find('label').html(i18n.current_default_org);
              }
            }
            this_favorite.show();

            this_checkbox.removeAttr("disabled");
          },
          error: function(data, textStatus, jqXHR){
            //hide the spinner and show the favorite is not selected
            this_spinner.addClass('hidden').hide();
            this_checkbox.attr("checked", false);
            this_favorite.show();
            this_checkbox.removeAttr("disabled");
          }
      });
      return false;
    };
    return {
        checkboxChanged: checkboxChanged
    };
}(jQuery));

var client_common = {
    create: function(data, url, on_success, on_error) {
      $.ajax({
        type: "POST",
        url: url,
        data: data,
        cache: false,
        success: on_success,
        error: on_error
      });
    },
    destroy: function(url, on_success, on_error) {
      $.ajax({
        type: "DELETE",
        url: url,
        cache: false,
        success: on_success,
        error: on_error
      });
    }
};

/**
 * Document Ready function
 */
$(document).ready(function (){
    KT.common.link_hover_setup('dark');

    //Add a handler so that if any input has focus
    //   our keyboard shortcuts don't steal it
    $(":input").focus(function() {
        onInputField = true;
    }).blur(function() {
        onInputField = false;
    });

    //Add a handler for helptips
    $(".helptip-open").live('click', KT.helptip.handle_close);
    $(".helptip-close").live('click', KT.helptip.handle_open);

    // Add a handler for ellipsis
    $(".one-line-ellipsis").ellipsis(true);
    $(".tipsify").tipsy({ live : true, gravity: 's', fade: true, delayIn : 350 });
    $(".tipsify-west").tipsy({ gravity: 'w', hoverable : 'true' });

    KT.tipsy.custom.enable_forms_tooltips();

    KT.common.orgSwitcherSetup();
    KT.common.orgFilterSetup();

});

/**
 * Window Ready function
 */
$(window).ready(function(){
    $('.fc').parent().css({"text-align":"center"});
    //all purpose display loading icon for ajax calls
    $("#loading").bind("ajaxSend", function(){
      $(this).show();
      $('body').css('cursor', 'wait');
    }).bind("ajaxComplete", function(){
      $(this).hide();
      $('body').css('cursor', 'default');
    });
    $().UItoTop({ easingType: 'easeOutQuart' });

    //allow all buttons with class .button to be clicked via enter or space button
    $('.button').live('keyup', function(e){
        if(e.which == 13 || e.which == 32)
        {
            $(this).click();
        }
    });

    window.alert = function(message){KT.common.customAlert(message);return false;};
    $.rails.confirm = function(message) {
        KT.common.customConfirm({message: message}); return false;
    };
});
