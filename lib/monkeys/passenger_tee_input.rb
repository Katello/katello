# In the candlepin proxy controllers we pass the request body
# straight from the request through to candlepin
# This does not have a seek() method which rest client needs
# to log properly.

if defined? PhusionPassenger
  module PhusionPassenger
    module Utils
      class TeeInput
        def seek(position)
          if position == 0
            rewind
          else
            fail "Seeking not supported to non zero position"
          end
        end
      end
    end
  end
end
