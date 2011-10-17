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

$(document).ready(function() {
    $('#search_favorite_save').live("click", favorite.save);
    $('#search_favorite_destroy').live("click", favorite.destroy);
});

var favorite = (function() {
    return {
        //custom successCreate - calls notices update and list/panel updates from panel.js
        success : function(data) {
            $(".qdropdown").html(data);

            // process the elements of the list and truncate any that are too long with ellipsis (...) (e.g. jquery.text-overflow.js)
            $(".one-line-ellipsis").ellipsis();
        },
        error : function(data) {
        },
        save : function(event) {
            // we want to submit the request using Ajax (prevent page refresh)
            event.preventDefault();

            var newFavorite = $('input[id^=search]').attr('value');
            var url = $(this).attr('data-url');

            // send a request to the server to save/create this favorite
            $.ajax({
                type: "POST",
                url: url,
                data: {"favorite": newFavorite},
                cache: false,
                success: favorite.success,
                error: favorite.error
            });

        },
        destroy : function (data) {
            var id  = $(this).attr('data-id');
            var url = $(this).attr('data-url');

            // send a request to the server to save/create this favorite
            client_common.destroy(url, favorite.success, favorite.error);
        }
    }
})();

KT.search = (function($){
	var enableAutoComplete = function(url){
		var request_issued = false,
		
			getAutoCompleteData = function(request, response){
				if( !request_issued ){
					request_issued = true;
		
					$.getJSON(url, { search	: request.term }, 
						function(json){
							request_issued = false;
							response(json);
						});
				}
			};
		
		$.widget( "custom.catcomplete", $.ui.autocomplete, {
			_renderMenu: function( ul, items ) {
		  		var self = this,
		  			currentCategory = "";
	
		  		$.each( items, function( index, item ) {
		    		if ( item.category != undefined && item.category != currentCategory ) {
		      			ul.append( "<li class='ui-autocomplete-category'>" + item.category + "</li>" );
		      			currentCategory = item.category;
		    		}
					if ( item.error != undefined ) {
					  	ul.append( "<li class='ui-autocomplete-error'>" + item.error + "</li>" );
					}
					if( item.completed != undefined ) {
					  	$( "<li></li>" ).data( "item.autocomplete", item )
							.append( "<a>" + "<strong class='ui-autocomplete-completed'>" + item.completed + "</strong>" + item.part + "</a>" )
							.appendTo( ul );
					    } else {
					      	self._renderItem( ul, item );
					    }
				});
			}
		});
		
		$(document).ready(function(){
			$("#search").catcomplete({
				source	: getAutoCompleteData,
				minLength: 0,
				delay	: 200,
				select	: function(event, ui) { $( this ).catcomplete( "search" , ui.item.value); },
				search	: function(event, ui) { $(".auto_complete_clear").hide(); },
				open	: function(event, ui) { $(".auto_complete_clear").show(); }
			});
			
			$("#search").live( "focus", function( event ) {
				if( $( this )[0].value == "" ) {
					$( this ).catcomplete( "search" );
				}
			});
		});
	};
	
	return {
		enableAutoComplete	: enableAutoComplete	
	};

})(jQuery);