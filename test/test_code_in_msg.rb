require "test/unit"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require "test_helper"
require "code_error"

class TestCodeInMsg < Test::Unit::TestCase

  ERROR_CODE_1 = 1
  ERROR_MSG_1 = 'The error message for code 1.'
  ERROR_STATUS_1 = :failed

  class AppendError < CodeError::Base
    def error_codes
      {
        ERROR_CODE_1 => {
          status: ERROR_STATUS_1,
          msg: ERROR_MSG_1,
        }
      }
    end

    def config
      super.merge({
        :code_in_msg => :append
      })
    end
  end

  class PrependError < CodeError::Base
    def error_codes
      {
        ERROR_CODE_1 => {
          status: ERROR_STATUS_1,
          msg: ERROR_MSG_1,
        }
      }
    end

    def config
      super.merge({
        :code_in_msg => :prepand
      })
    end
  end

  class NoneError < CodeError::Base
    def error_codes
      {
        ERROR_CODE_1 => {
          status: ERROR_STATUS_1,
          msg: ERROR_MSG_1,
        }
      }
    end

    def config
      super.merge({
        :code_in_msg => :none
      })
    end
  end

  def test_code_in_msg_should_return_a_message_with_the_code_appended_after_it_if_append_config_is_given
    e = AppendError.new(ERROR_CODE_1)
    assert(e.msg == "#{ERROR_MSG_1}(#{ERROR_CODE_1})")
  end

  def test_code_in_msg_should_return_a_message_with_the_code_prepended_before_it_if_prepend_config_is_given
    e = PrependError.new(ERROR_CODE_1)
    assert(e.msg == "(#{ERROR_CODE_1})#{ERROR_MSG_1}")
  end

  def test_code_in_msg_should_return_a_message_without_the_code_if_none_config_is_given
    e = NoneError.new(ERROR_CODE_1)
    assert(e.msg == "#{ERROR_MSG_1}")
  end

  def test_code_in_msg_should_return_a_message_without_the_code_if_it_is_a_success_error
    e = AppendError.new(CodeError::SUCCESS_CODE)
    assert(e.msg == "#{CodeError::SUCCESS_MSG}")
    e = PrependError.new(CodeError::SUCCESS_CODE)
    assert(e.msg == "#{CodeError::SUCCESS_MSG}")
  end
end
