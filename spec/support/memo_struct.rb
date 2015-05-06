# Implementation of OpenStruct without obj.id deprectaion warning
class MemoStruct
  def initialize(hash = {})
    @hash = hash
  end

  def id
    @hash[:id]
  end

  def method_missing(method, *args)
    if method.to_s =~ /^(.*)=$/
      @hash[Regexp.last_match[1].to_sym] = args.first
    else
      @hash[method]
    end
  end
end
