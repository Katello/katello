# Fixed in later versions of 3.2 (like 3.2.13 or 3.2.14 maybe)
# Rails doesn't handle multipart json correctly
# See http://stackoverflow.com/a/14269110

module ActiveSupport::JSON::Encoding
  def self.escape(string)
    if string.respond_to?(:force_encoding)
      string = string.encode(::Encoding::UTF_8, :undef => :replace).force_encoding(::Encoding::BINARY)
    end
    json = string.gsub(escape_regex) { |s| ESCAPED_CHARS[s] }
    json = %("#{json}")
    json.force_encoding(::Encoding::UTF_8) if json.respond_to?(:force_encoding)
    json
  end
end
