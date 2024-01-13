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

    task = q.pop
    q.failed(task.id)
  end

  def test_no_rows_to_pop_returns_nil
    q = QueueLite::Queue.build(":memory:")

    assert_nil q.pop
  end
end
