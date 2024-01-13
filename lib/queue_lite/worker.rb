# frozen-string-literal: true

require "json"

module QueueLite
  class Worker
    def initialize(queue)
      @queue = queue
      @running = false
    end

    def run
      @running = true
      while @running
        perform_once
      end
    end

    def perform_once
      task = queue.pop
      return if task.nil?

      klass, *args = JSON.parse(task.data)
      begin
        Object.const_get(klass).perform(*args).tap do
          queue.done(task.id)
        end
      rescue
        queue.failed(task.id)
      end
    end

    def shutdown
      @running = false
    end

    private

    attr_reader :queue
  end
end
