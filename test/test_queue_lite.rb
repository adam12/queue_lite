# frozen_string_literal: true

require "test_helper"

class Job
  def self.perform(arg_1, arg_2)
    [arg_1, arg_2]
  end
end

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

  def test_work_queue
    require "json"
    q = QueueLite::Queue.build(":memory:")
    3.times do
      q.put(JSON.generate(["Job", 1, 2]))
    end

    3.times do
      task = q.pop
      klass, *args = JSON.parse(task.data)
      result = Object.const_get(klass).perform(*args)
      q.done(task.id)
      assert_equal [1, 2], result
    end
  end
end
