require "test/unit"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require "test_helper"
require "code_error"

class TestNew < Test::Unit::TestCase

  class InvalidError < CodeError::Base; end;

  ERROR_CODE_1 = 1
  ERROR_MSG_1 = 'The error message for code 1.'
  ERROR_STATUS_1 = :failed

  ERROR_CODE_2 = 2
  ERROR_MSG_2 = 'The error message for code 2.'
  ERROR_STATUS_2 = :failed

  ERROR_CODE_UNDEFINED = 55688

  class TestError < CodeError::Base
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

  def test_new_should_raise_an_exception_if_the_error_codes_is_undefined
    assert_raise(RuntimeError) { InvalidError.new }
  end

  def test_new_should_return_the_correspond_data_if_given_code_is_defined
    e = TestError.new(ERROR_CODE_1)
    assert(e.code == ERROR_CODE_1)
    assert(e.status == ERROR_STATUS_1)
    assert(e.msg == "#{ERROR_MSG_1}(#{ERROR_CODE_1})")
    assert(e.data == { :code => ERROR_CODE_1,
                       :status => ERROR_STATUS_1,
                       :msg => "#{ERROR_MSG_1}(#{ERROR_CODE_1})",
                       :info => {} })
    assert(e.message == e.data.inspect)
    assert(!e.internal?)
  end

  def test_new_should_return_an_internal_error_with_given_code_if_given_code_is_undefined
    e = TestError.new(ERROR_CODE_UNDEFINED)
    assert(e.code == ERROR_CODE_UNDEFINED)
    assert(e.status == CodeError::INTERNAL_STATUS)
    assert(e.msg == "#{CodeError::INTERNAL_MSG}(#{ERROR_CODE_UNDEFINED})")
    assert(e.internal?)
  end

  def test_new_should_return_an_internal_error_with_given_msg_if_given_code_is_a_string
    msg = 'An error message.'
    e = TestError.new(msg)
    assert(e.code == CodeError::INTERNAL_CODE)
    assert(e.status == CodeError::INTERNAL_STATUS)
    assert(e.msg == "#{msg}(#{CodeError::INTERNAL_CODE})")
    assert(e.internal?)
  end

  def test_new_should_return_an_success_error_if_given_code_is_a_success_code
    e = TestError.new(CodeError::SUCCESS_CODE)
    assert(e.code == CodeError::SUCCESS_CODE)
    assert(e.status == CodeError::SUCCESS_STATUS)
    assert(e.msg == "#{CodeError::SUCCESS_MSG}")
    assert(!e.internal?)
  end

  def test_new_should_mask_the_msg_if_given_msg_is_masked
    e = TestError.new(ERROR_CODE_1, :masked)
    assert(e.code == ERROR_CODE_1)
    assert(e.status == ERROR_STATUS_1)
    assert(e.msg == "#{CodeError::MASKED_MSG}(#{ERROR_CODE_1})")
    assert(!e.internal?)
  end

  def test_new_should_mask_the_msg_by_default_if_true_masked_config_is_given
    e = TestError.new(ERROR_CODE_2)
    assert(e.code == ERROR_CODE_2)
    assert(e.status == ERROR_STATUS_2)
    assert(e.msg == "#{CodeError::MASKED_MSG}(#{ERROR_CODE_2})")
    assert(!e.internal?)
  end

  def test_new_should_contain_the_info_if_an_info_is_given
    info = 'some information'
    e = TestError.new(ERROR_CODE_1, nil, info)
    assert(e.info == info)
  end
end
