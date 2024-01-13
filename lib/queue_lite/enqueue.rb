# frozen-string-literal: true

require "json"

module QueueLite
  class Enqueue < Module
    def initialize(queue)
      define_method :enqueue do |*args|
        queue.put(JSON.generate([self.class.to_s, *args]))
        true
      end
    end
  end
end
