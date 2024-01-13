# frozen_string_literal: true

require_relative "queue_lite/version"

module QueueLite
  class Error < StandardError; end

  require_relative "queue_lite/enqueue"
  require_relative "queue_lite/worker"
  require_relative "queue_lite/queue"
end
