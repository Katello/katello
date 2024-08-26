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
        customAlert : function(message) {
          var html = "<div style='margin:20px;'><span class='status_exclamation_icon'/><div style='margin-left: 24px; display:table;height:1%;'>" + message + "</div></div>";
          $(html).dialog({
            closeOnEscape: true,
            open: function (event, ui) { $('.ui-dialog-titlebar-close').hide(); },
            modal: true,
            resizable: false,
            width: 300,
            title: katelloI18n.alert,
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
                  'text' : katelloI18n.ok
                }
            }
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
          return document.querySelector('#sync_toggle_cont').dataset.spinnerAssetPath;
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
            $('a').on('mouseenter',
                function(){
                    KT.common.icon_hover_change($(this), shade); }
            ).on('mouseleave',
                function(){ KT.common.icon_hover_change($(this), shade); }
            );
        }
    };
})(jQuery);
