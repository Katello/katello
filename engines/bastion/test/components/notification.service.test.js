describe('Factory: Nofification', function() {
    var Notification, foreman;

    beforeEach(module('Bastion.components'));

    beforeEach(module(function ($provide) {
        foreman = {
            toastNotifications: {
                notify: function () {}
            }
        };

        $provide.value('foreman', foreman);
    }));

    beforeEach(inject(function (_Notification_) {
        Notification = _Notification_;
        spyOn(foreman.toastNotifications, 'notify');
    }));

    it("provides a way to set error messages", function () {
        var message = "Everything is broken!";
        Notification.setErrorMessage(message);
        expect(foreman.toastNotifications.notify).toHaveBeenCalledWith({message: message, type: 'danger'});
    });

    it("provides a way to set warning messages", function () {
        var message = "Everything ran correctly!";
        Notification.setWarningMessage(message);
        expect(foreman.toastNotifications.notify).toHaveBeenCalledWith({message: message, type: 'warning'});
    });

    it("provides a way to set success messages", function () {
        var message = "Everything ran correctly!";
        Notification.setSuccessMessage(message);
        expect(foreman.toastNotifications.notify).toHaveBeenCalledWith({message: message, type: 'success'});
    });

    it("allows message context to be specified for interpolation", function () {
        var message = "Everything ran correctly {{ ending }}!",
            options = {link: "", context: {ending: 'yay'}},
            expectedMessage = 'Everything ran correctly yay!';

        Notification.setSuccessMessage(message, options);
        expect(foreman.toastNotifications.notify).toHaveBeenCalledWith({message: expectedMessage, type: 'success', link: options.link});
    });

    it("provides link to success task", function () {
        var message = "Everything ran correctly!";
        options = {link: "www.redhat.com"};
        Notification.setSuccessMessage(message, options);
        expect(foreman.toastNotifications.notify).toHaveBeenCalledWith({message: message, type: 'success', link: options.link});
    });
});
