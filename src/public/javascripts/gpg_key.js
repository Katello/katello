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

KT.panel.list.registerPage('gpg_keys', { create : 'new_gpg_key' });

$(document).ready(function(){
	$('#gpg_key_content').live('input keyup paste', function(){
		if( $(this).val() !== '' ){
			$('#gpg_key_content_upload').attr('disabled', 'disabled');
		} else {
			$('#gpg_key_content_upload').removeAttr('disabled');
		}
	});
	
	$('#gpg_key_content_upload').live('change', function(){
		if( $(this).val() !== '' ){
			$('#gpg_key_content').attr('disabled', 'disabled');
			$('#cancel_upload_button').removeAttr('disabled');
		} else {
			$('#gpg_key_content').removeAttr('disabled');
			$('#cancel_upload_button').attr('disabled', 'disabled');
		}
	});
	
	$('#cancel_upload_button').live('click', function(){
		$('#gpg_key_content_upload').val('');
		$('#gpg_key_content').removeAttr('disabled');
		$('#cancel_upload_button').attr('disabled', 'disabled');
	});
});
