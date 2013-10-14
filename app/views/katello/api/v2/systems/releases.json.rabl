node :results do
    @collection[:releases].map do |release|
        release
    end
end

