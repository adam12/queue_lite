# frozen_string_literal: true

require "test_helper"

class TestQueueLite < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::QueueLite::VERSION
  end

  def test_implementation
    q = QueueLite::Queue.build(":memory:")

    q.put("Hello")
    q.put("World")

    task = q.pop

    q.done(task.id)
    q.get(task.id)
  end
end
