require "test/unit"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require "test_helper"
require "code_error"

class TestMasked < Test::Unit::TestCase

  ERROR_CODE_1 = 1
  ERROR_MSG_1 = 'The error message for code 1.'
  ERROR_STATUS_1 = :failed

  ERROR_CODE_2 = 2
  ERROR_MSG_2 = 'The error message for code 2.'
  ERROR_STATUS_2 = :failed

  ERROR_CODE_UNDEFINED = 55688

  class MaskedError < CodeError::Base
    def error_codes
      {
        ERROR_CODE_1 => {
          :status => ERROR_STATUS_1,
          :msg => ERROR_MSG_1,
        },
        ERROR_CODE_2 => {
          :status => ERROR_STATUS_2,
          :msg => ERROR_MSG_2,
          :masked => true
        }
      }
    end
  end

  def test_masked_should_mask_the_message_if_the_true_masked_arg_is_given_in_msg_and_data
    e = MaskedError.new(ERROR_CODE_1)
    assert(e.msg(true) == "#{CodeError::MASKED_MSG}(#{ERROR_CODE_1})")
    assert(e.data(true) == { :code => ERROR_CODE_1,
                             :status => ERROR_STATUS_1,
                             :msg => "#{CodeError::MASKED_MSG}(#{ERROR_CODE_1})",
                             :info => {} })
  end

  def test_masked_should_mask_the_message_if_given_code_is_undefined_but_the_true_masked_arg_is_given_in_msg_and_data
    e = MaskedError.new(ERROR_CODE_UNDEFINED)
    assert(e.msg(true) == "#{CodeError::MASKED_MSG}(#{ERROR_CODE_UNDEFINED})")
    assert(e.data(true) == { :code => ERROR_CODE_UNDEFINED,
                             :status => CodeError::INTERNAL_STATUS,
                             :msg => "#{CodeError::MASKED_MSG}(#{ERROR_CODE_UNDEFINED})",
                             :info => {} })
  end

  def test_masked_should_mask_the_message_if_given_code_is_a_string_but_the_true_masked_arg_is_given_in_msg_and_data
    msg = 'An error message.'
    e = MaskedError.new(msg)
    assert(e.msg(true) == "#{CodeError::MASKED_MSG}(#{CodeError::INTERNAL_CODE})")
    assert(e.data(true) == { :code => CodeError::INTERNAL_CODE,
                             :status => CodeError::INTERNAL_STATUS,
                             :msg => "#{CodeError::MASKED_MSG}(#{CodeError::INTERNAL_CODE})",
                             :info => {} })
  end

  def test_masked_should_mask_the_message_if_given_code_is_a_success_code_but_the_true_masked_arg_is_given_in_msg_and_data
    e = MaskedError.new(CodeError::SUCCESS_CODE)
    assert(e.msg(true) == "#{CodeError::MASKED_MSG}")
    assert(e.data(true) == { :code => CodeError::SUCCESS_CODE,
                             :status => CodeError::SUCCESS_STATUS,
                             :msg => "#{CodeError::MASKED_MSG}",
                             :info => {} })
  end

  def test_masked_should_unmask_the_message_if_given_msg_is_masked_in_new_but_the_false_masked_arg_is_given_in_msg_and_data
    e = MaskedError.new(ERROR_CODE_1, :masked)
    assert(e.msg(false) == "#{ERROR_MSG_1}(#{ERROR_CODE_1})")
    assert(e.data(false) == { :code => ERROR_CODE_1,
                              :status => ERROR_STATUS_1,
                              :msg => "#{ERROR_MSG_1}(#{ERROR_CODE_1})",
                              :info => {} })
  end

  def test_masked_should_unmask_the_message_if_true_masked_config_is_given_but_the_false_masked_arg_is_given_in_msg_and_data
    e = MaskedError.new(ERROR_CODE_2)
    assert(e.msg(false) == "#{ERROR_MSG_2}(#{ERROR_CODE_2})")
    assert(e.data(false) == { :code => ERROR_CODE_2,
                              :status => ERROR_STATUS_2,
                              :msg => "#{ERROR_MSG_2}(#{ERROR_CODE_2})",
                              :info => {} })
  end
end
