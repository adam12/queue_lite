# frozen_string_literal: true

require_relative "queue_lite/version"
require "sqlite3"

module QueueLite
  class Error < StandardError; end

  class Queue
    READY_STATUS = "ready"
    LOCKED_STATUS = "locked"
    FAILED_STATUS = "failed"

    Task = Data.define(:id, :data) do
      def initialize(data: nil, **)
        super
      end
    end

    def self.build(connection_string)
      db = SQLite3::Database.new(connection_string)

      new(db).tap do |instance|
        instance.prepare
      end
    end

    def initialize(db)
      @db = db
    end

    def prepare
      db.execute("PRAGMA journal_mode = 'WAL';")

      db.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS queue
        (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          data TEXT,
          status TEXT
        )
      SQL
    end

    def put(data)
      row = db.get_first_row(<<~SQL, [data, READY_STATUS])
        INSERT INTO queue(data, status) VALUES(?, ?)
        RETURNING id, data
      SQL

      Task.new(*row)
    end

    def pop
      row = db.get_first_row(<<~SQL, [LOCKED_STATUS, READY_STATUS])
        UPDATE queue
        SET status = ?
        WHERE rowid = (SELECT rowid
                       FROM queue
                       WHERE status = ?
                       ORDER BY id
                       LIMIT 1)
        RETURNING id, data
      SQL

      return if row.nil?

      Task.new(*row)
    end

    def done(id)
      row = db.get_first_row(<<~SQL, [LOCKED_STATUS, id])
        UPDATE queue
        SET status = ?
        WHERE id = ?
        RETURNING id, data
      SQL

      Task.new(*row)
    end

    def failed(id)
      row = db.get_first_row(<<~SQL, [FAILED_STATUS, id])
        UPDATE queue
        SET status = ?
        WHERE id = ?
        RETURNING id, data
      SQL

      Task.new(*row)
    end

    def get(id)
      row = db.get_first_row(<<~SQL, [id])
        SELECT id, data
        FROM queue
        WHERE id = ?
        LIMIT 1
      SQL

      Task.new(*row)
    end

    private

    attr_reader :db
  end
end
