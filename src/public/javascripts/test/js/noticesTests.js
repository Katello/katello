test('addNotices()', function() {
    var jData = {"new_notices": [
          {"id": "1", "text": "this is a test", "level": "error"},
          {"id": "2", "text": "this is another test", "level": "warning"}
          ], "unread_count": 3 };
    notices.addNotices(jData);
    ok($('.jnotify-container').length > 0, "JNotify container is displayed");
    equals($('.jnotify-message').length, 2 , "Two JNotify messages are displayed");
})
