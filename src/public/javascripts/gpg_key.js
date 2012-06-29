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

KT.panel.list.registerPage('gpg_keys', { 
    create              : 'new_gpg_key',
    extra_create_data   : function(){
		return { 'gpg_key[name]' : $('#gpg_key_name').val() };
    }

});

$(document).ready(function(){
	$('#upload_gpg_key').live('click', function(event){
		KT.gpg_key.upload();
	});

	$('#upload_new_gpg_key').live('submit', function(e){
    e.preventDefault();
    KT.gpg_key.upload();
	});
	
	$('#update_upload_gpg_key').live('click', function(event){
		KT.gpg_key.upload_update();
	});
	
	$('#gpg_key_content').live('input keyup paste', function(){
		if( $(this).val() !== '' ){
			$('#gpg_key_content_upload').attr('disabled', 'disabled');
			$('#upload_gpg_key').attr('disabled', 'disabled');
			$('#clear_gpg_key').removeAttr('disabled');
		} else {
			$('#gpg_key_content_upload').removeAttr('disabled');
			$('#upload_gpg_key').removeAttr('disabled');
			$('#clear_gpg_key').attr('disabled', 'disabled');
		}
	});
	
	$('#gpg_key_content_upload').live('change', function(){
		if( $(this).val() !== '' ){
			$('#gpg_key_content').attr('disabled', 'disabled');
			$('#save_gpg_key').attr('disabled', 'disabled');
			$('#clear_upload_gpg_key').removeAttr('disabled');
		} else {
			$('#gpg_key_content').removeAttr('disabled');
			$('#save_gpg_key').removeAttr('disabled');
			$('#clear_upload_gpg_key').attr('disabled', 'disabled');
		}
	});
	
		
	$('#clear_upload_gpg_key').live('click', function(){
		$('#gpg_key_content_upload').val('');
		$('#gpg_key_content').removeAttr('disabled');
		$('#save_gpg_key').removeAttr('disabled');
		$('#clear_upload_gpg_key').attr('disabled', 'disabled');
		$('#clear_gpg_key').attr('disabled', 'disabled');
	});
	
	$('#clear_gpg_key').live('click', function(){
		$('#gpg_key_content').val('');
		$('#gpg_key_content_upload').removeAttr('disabled');
		$('#upload_gpg_key').removeAttr('disabled');
		$('#clear_upload_gpg_key').attr('disabled', 'disabled');
		$('#clear_gpg_key').attr('disabled', 'disabled');
	});

	$('#gpg_key_content_upload_update').live('change', function(){
		if( $(this).val() !== '' ){
			$('#update_upload_gpg_key').removeAttr('disabled');
			$('#clear_upload_gpg_key').removeAttr('disabled');
		} else {
			$('#update_upload_gpg_key').attr('disabled', 'disabled');
			$('#clear_upload_gpg_key').attr('disabled', 'disabled');
		}
	});
	
	$('#clear_upload_gpg_key').live('click', function(){
		$('#update_upload_gpg_key').attr('disabled', 'disabled');
		$('#clear_upload_gpg_key').attr('disabled', 'disabled');
		$('#gpg_key_content_upload_update').val('');
	});
});

KT.gpg_key = (function($){
	var self = this,
	
		get_buttons = function(){
			return {
				'gpg_key_save'	: $('#save_gpg_key'),
				'gpg_key_upload': $('#upload_gpg_key')
			}
		},
		enable_buttons = function(){
			var buttons = get_buttons();
			buttons.gpg_key_save.removeAttr('disabled');
			buttons.gpg_key_upload.removeAttr('disabled');
		},
		disable_buttons = function(){
			var buttons = get_buttons();
			buttons.gpg_key_save.attr('disabled', 'disabled');
			buttons.gpg_key_upload.attr('disabled', 'disabled');
		};
	
	self.upload = function(){
		var submit_data = { 'gpg_key[name]' : $('#gpg_key_name').val() };
		
		disable_buttons();
		
		$('#upload_new_gpg_key').ajaxSubmit({
			url 	: KT.routes['gpg_keys_path'](),
			type 	: 'POST',
			data 	: submit_data,
			iframe	: true,
			success	: function(data, status, xhr){
				var parsed_data = $(data);
				if( parsed_data.get(0).tagName === 'PRE' ){
					notices.displayNotice('error', parsed_data.html());
				} else {
					KT.panel.list.createSuccess(data);
				}
				
				enable_buttons();
			},
			error	: function(){
                enable_buttons();
                notices.checkNotices();
			}
		});
	};
	
	self.upload_update = function(){
		$('#update_upload_gpg_key').attr('disabled', 'disabled');
		$('#clear_upload_gpg_key').attr('disabled', 'disabled');

		$('#upload_gpg_key').ajaxSubmit({
			url 	: $(this).data('url'),
			type 	: 'POST',
			iframe	: true,
			success	: function(data, status, xhr){
                if( !data.match(/notices/) ){
                    $('#gpg_key_content').html(data);
                    $('#upload_gpg_key').val('');		
                }
                notices.checkNotices();
                $('#update_upload_gpg_key').removeAttr('disabled');
                $('#clear_upload_gpg_key').removeAttr('disabled');
			},
			error	: function(){
                $('#update_upload_gpg_key').removeAttr('disabled');
				$('#clear_upload_gpg_key').removeAttr('disabled');
                notices.checkNotices();
			}
		});
	};
	
	return self;
	
})(jQuery);
