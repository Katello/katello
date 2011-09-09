/**
 Copyright 2011 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/



var notices = (function() {
    return {
        setup_notices: function(pollingTimeOut) {
          if (pollingTimeOut === undefined) {
            pollingTimeOut = 45000;
          }
          
          notices.checkTimeout = pollingTimeOut;
          //start continual checking for new notifications
          notices.start();
        },
        displayNotice: function(level, notices) {
            var notices= $.parseJSON(notices),
                options = {
                    type: level, 
                    slideSpeed: 200,
                    alwaysClosable: true
                },
                generate_list = function(notices){
                    var notices_list = '<ul>',
                        i, length = notices.length;
                    
                    for( i=0; i < length; i += 1) {
                        notices_list += '<li>' + notices[i] + '</li>';
                    }
                    notices_list += '</ul>';

                    return notices_list;
                };
            
            if ((level === "error") || (level === "warning")) {
                options["sticky"] = true;
                options["fadeSpeed"] = 600;
            } else {
                options["sticky"] = false;
                options["fadeSpeed"] = 600;
            }

            if( notices['validation_errors'] !== undefined ){
                var validation_html = generate_list(notices['validation_errors']);
                validation_html = '<span>' + i18n.validation_errors + '</span>' + validation_html;
                $.jnotify(validation_html, options);
                $('.jnotify-message ul').css({'list-style': 'disc',
                              'margin-left': '30px'});    
            } 
            if( notices['notices'].length !== 0 ){
                $.jnotify(generate_list(notices['notices']), options);
            }  
        },
        addNotices: function(data) {
            if (!data || data.new_notices.length === 0) {
                return true;
            }

            //if coming from the server may have new count
            if (data.unread_count) {
                $("#unread_notices").text(data.unread_count);
            }

            
            
            $.each(data.new_notices, function(index, notice) {
                notices.displayNotice(notice.level, window.JSON.stringify({ "notices": [notice.text] }));
            });

            return true;
        },
        checkNotices : function() {
            var url = $('#get_notices_url').attr('data-url');

            //Make sure when we load the page we get notifs
            $.ajax({
              type: 'GET',
              url: url,
              dataType: 'json',
              global: false,
              success: notices.addNotices
              
            });
        },
        checkNoticesInResponse : function(xhr) {
            if (xhr !== undefined) {
                var message = KT.common.decode(xhr.getResponseHeader('X-Message'));
                if (message === "null") {message = null;}
                var messageType = xhr.getResponseHeader('X-Message-Type');
                if (message) {
                    notices.displayNotice(messageType, message);
                }
            }
        },
        start: function () {
            var url = $('#get_notices_url').attr('data-url');
            var pu = $.PeriodicalUpdater(url, {
                method: 'get',
                type: 'json',
                global: false,
                minTimeout: notices.checkTimeout,
                maxTimeout: notices.checkTimeout
            }, notices.addNotices);

        }
    };
})();

$(document).ready(function() {

    // perform periodic polling of notices (e.g. async scenarios)
    //notices.checkNotices();

    $(document).ajaxComplete(function(event, xhr, options){
        // look for notices in the response (e.g. sync scenarios)
        notices.checkNoticesInResponse(xhr);
    });
});
