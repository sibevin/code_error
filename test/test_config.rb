require "test/unit"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require "test_helper"
require "code_error"

class TestConfig < Test::Unit::TestCase

  ERROR_CODE_1 = 1
  ERROR_MSG_1 = 'The error message for code 1.'
  ERROR_STATUS_1 = :failed

  ERROR_CODE_2 = 2
  ERROR_MSG_2 = 'The error message for code 2.'
  ERROR_STATUS_2 = :failed

  ERROR_CODE_UNDEFINED = 55688

  MY_SUCCESS_CODE = :my_success_code
  MY_SUCCESS_MSG = 'My success error message.'
  MY_SUCCESS_STATUS = :my_success_status

  MY_INTERNAL_CODE = :my_internal_code
  MY_INTERNAL_MSG = 'My internal error message.'
  MY_INTERNAL_STATUS = :my_internal_status

  MY_MASKED_MSG = 'My masked message.'

  class ConfigError < CodeError::Base
    def error_codes
      {
        ERROR_CODE_1 => {
          status: ERROR_STATUS_1,
          msg: ERROR_MSG_1,
        },
        ERROR_CODE_2 => {
          :status => ERROR_STATUS_2,
          :msg => ERROR_MSG_2,
          :masked => true
        }
      }
    end

    def config
      {
        :success => {
          :code => MY_SUCCESS_CODE,
          :msg => MY_SUCCESS_MSG,
          :status => MY_SUCCESS_STATUS
        },
        :internal => {
          :code => MY_INTERNAL_CODE,
          :msg => MY_INTERNAL_MSG,
          :status => MY_INTERNAL_STATUS
        },
        :masked_msg => MY_MASKED_MSG,
        :code_in_msg => :append
      }
    end
  end

  def test_config_should_return_the_correspond_data_if_given_code_is_defined
    e = ConfigError.new(ERROR_CODE_1)
    assert(e.code == ERROR_CODE_1)
    assert(e.status == ERROR_STATUS_1)
    assert(e.msg == "#{ERROR_MSG_1}(#{ERROR_CODE_1})")
    assert(!e.internal?)
  end

  def test_config_should_return_an_internal_error_with_given_code_if_given_code_is_undefined
    e = ConfigError.new(ERROR_CODE_UNDEFINED)
    assert(e.code == ERROR_CODE_UNDEFINED)
    assert(e.status == MY_INTERNAL_STATUS)
    assert(e.msg == "#{MY_INTERNAL_MSG}(#{ERROR_CODE_UNDEFINED})")
    assert(e.internal?)
  end

  def test_config_should_return_an_internal_error_with_given_msg_if_given_code_is_a_string
    msg = 'An error message.'
    e = ConfigError.new(msg)
    assert(e.code == MY_INTERNAL_CODE)
    assert(e.status == MY_INTERNAL_STATUS)
    assert(e.msg == "#{msg}(#{MY_INTERNAL_CODE})")
    assert(e.internal?)
  end

  def test_config_should_return_an_success_error_if_given_code_is_a_success_code
    e = ConfigError.new(MY_SUCCESS_CODE)
    assert(e.code == MY_SUCCESS_CODE)
    assert(e.status == MY_SUCCESS_STATUS)
    assert(e.msg == "#{MY_SUCCESS_MSG}")
    assert(!e.internal?)
  end

  def test_config_should_mask_the_msg_if_given_msg_is_masked
    e = ConfigError.new(ERROR_CODE_1, :masked)
    assert(e.code == ERROR_CODE_1)
    assert(e.status == ERROR_STATUS_1)
    assert(e.msg == "#{MY_MASKED_MSG}(#{ERROR_CODE_1})")
    assert(!e.internal?)
  end

  def test_config_should_mask_the_msg_by_default_if_true_masked_config_is_given
    e = ConfigError.new(ERROR_CODE_2)
    assert(e.code == ERROR_CODE_2)
    assert(e.status == ERROR_STATUS_2)
    assert(e.msg == "#{MY_MASKED_MSG}(#{ERROR_CODE_2})")
    assert(!e.internal?)
  end

  def test_config_should_contain_the_info_if_an_info_is_given
    info = 'some information'
    e = ConfigError.new(ERROR_CODE_1, nil, info)
    assert(e.info == info)
  end
end
