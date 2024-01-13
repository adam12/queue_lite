# frozen_string_literal: true

require_relative "queue_lite/version"
require "sqlite3"

module QueueLite
  class Error < StandardError; end

  class Queue
    READY_STATUS = "ready"
    LOCKED_STATUS = "locked"

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

    def put(message)
      row = db.execute(<<~SQL, [message, READY_STATUS]).first
        INSERT INTO queue(data, status) VALUES(?, ?)
        RETURNING id, data
      SQL

      Task.new(*row)
    end

    def pop
      row = db.execute(<<~SQL, [LOCKED_STATUS, READY_STATUS]).first
        UPDATE queue
        SET status = ?
        WHERE rowid = (SELECT rowid
                       FROM queue
                       WHERE status = ?
                       ORDER BY id
                       LIMIT 1)
        RETURNING id, data
      SQL

      Task.new(*row)
    end

    def done(id)
      row = db.execute(<<~SQL, [LOCKED_STATUS, id]).first
        UPDATE queue
        SET status = ?
        WHERE id = ?
        -- LIMIT 1 -- Why doesn't this work
        RETURNING id, data
      SQL

      Task.new(*row)
    end

    def get(id)
      row = db.execute(<<~SQL, [id]).first
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
