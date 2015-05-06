module Katello
  class ContentSearch::Cell
    include ContentSearch::Element
    display_attributes :id, :display, :hover, :hover_details, :content

    def as_json(_options = nil)
      to_ret = {
        :id => id
      }
      to_ret[:content] = content unless content.nil?
      to_ret[:display] = display unless display.nil?
      to_ret[:hover] = self.hover.nil? ? '' : self.hover.call
      to_ret[:hover_details] = self.hover_details.nil? ? '' : self.hover_details.call
      to_ret
    end
  end
end
