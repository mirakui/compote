module Compote
  module Pipeline
    module Task
      class Base
        def get_ym(year=nil, month=nil)
          t = Time.now
          Time.new(year || t.year, month || t.month).strftime('%y%m')
        end
      end
    end
  end
end
