module LocaleHelperMethods
  def set_default_locale
    request.env['HTTP_ACCEPT_LANGUAGE'] = 'en-US'
  end
end
