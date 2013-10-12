/**
 * Copyright 2013 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 */

//requires jQuery
KT.common = (function() {
    var root_url;
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
            return myid.replace(/([ #;&,.%+*~\':"!\^$\[\]()=>|\/])/g,'\\$1');
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
          confirmTrue = true,
          confirmFalse = false;

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
             $('.favorite').live('click', function(e) {
                KT.orgswitcher.checkboxChanged($(this).parent().find('.default_org'));
            });
        },
        rootURL : function() {
            if (root_url === undefined) {
                root_url = KT.routes.options.prefix;
            }
            return root_url;
        },
        getSearchParams : function(val) {
            var search_string;

            if ($.bbq) {
                search_string = $.bbq.getState('list_search');
            }

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

            if (bytes === 0) {
                return '0';
            } else {
                i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)), 10);
                return ((i === 0) ? (bytes / Math.pow(1024, i)) : (bytes / Math.pow(1024, i)).toFixed(1)) + ' ' + sizes[i];
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
