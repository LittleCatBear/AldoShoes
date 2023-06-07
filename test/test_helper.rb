# typed: false
# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'byebug'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    def with_logger(&block)
      orig_logger = Rails.logger.dup
      @logger_output = StringIO.new
      begin
        Rails.logger = ActiveSupport::Logger.new(@logger_output)
        block.call(@logger_output)
      ensure
        Rails.logger = orig_logger
      end
    end
  end
end
