require "minitest/autorun"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require "test_helper"
require "code_error"

class TestConfig < Minitest::Test

  CONFIG_ERROR_CODE_1 = :config_code1
  CONFIG_ERROR_MSG_1 = 'The config error message for code 1.'
  CONFIG_ERROR_STATUS_1 = :config_failed

  CONFIG_ERROR_CODE_2 = :config_code2
  CONFIG_ERROR_MSG_2 = 'The config error message for code 2.'
  CONFIG_ERROR_STATUS_2 = :config_failed

  CONFIG_ERROR_CODE_UNDEFINED = :config_undefined_code

  MY_SUCCESS_CODE = :my_config_success_code
  MY_SUCCESS_MSG = 'My config success error message.'
  MY_SUCCESS_STATUS = :my_config_success_status

  MY_INTERNAL_CODE = :my_config_internal_code
  MY_INTERNAL_MSG = 'My config internal error message.'
  MY_INTERNAL_STATUS = :my_config_internal_status

  MY_MASKED_MSG = 'My config masked message.'

  class ConfigError < CodeError::Base
    error_codes({
      CONFIG_ERROR_CODE_1 => {
        status: CONFIG_ERROR_STATUS_1,
        msg: CONFIG_ERROR_MSG_1,
      },
      CONFIG_ERROR_CODE_2 => {
        :status => CONFIG_ERROR_STATUS_2,
        :msg => CONFIG_ERROR_MSG_2,
        :masked => true
      }
    })

    success({
      :code => MY_SUCCESS_CODE,
      :msg => MY_SUCCESS_MSG,
      :status => MY_SUCCESS_STATUS
    })

    internal({
      :code => MY_INTERNAL_CODE,
      :msg => MY_INTERNAL_MSG,
      :status => MY_INTERNAL_STATUS
    })

    masked_msg MY_MASKED_MSG
  end

  def test_config_should_return_the_correspond_data_if_given_code_is_defined
    e = ConfigError.gen(CONFIG_ERROR_CODE_1)
    assert(e.code == CONFIG_ERROR_CODE_1)
    assert(e.status == CONFIG_ERROR_STATUS_1)
    assert(e.msg == CONFIG_ERROR_MSG_1)
    assert(!e.internal?)
  end

  def test_config_should_return_an_internal_error_with_given_code_if_given_code_is_undefined
    e = ConfigError.gen(CONFIG_ERROR_CODE_UNDEFINED)
    assert(e.code == CONFIG_ERROR_CODE_UNDEFINED)
    assert(e.status == MY_INTERNAL_STATUS)
    assert(e.msg == MY_INTERNAL_MSG)
    assert(e.internal?)
  end

  def test_config_should_return_an_internal_error_with_given_msg_if_given_code_is_a_string
    msg = 'An error message.'
    e = ConfigError.gen(msg)
    assert(e.code == MY_INTERNAL_CODE)
    assert(e.status == MY_INTERNAL_STATUS)
    assert(e.msg == msg)
    assert(e.internal?)
  end

  def test_config_should_return_an_success_error_if_given_code_is_a_success_code
    e = ConfigError.gen(MY_SUCCESS_CODE)
    assert(e.code == MY_SUCCESS_CODE)
    assert(e.status == MY_SUCCESS_STATUS)
    assert(e.msg == MY_SUCCESS_MSG)
    assert(!e.internal?)
  end

  def test_config_should_mask_the_msg_if_given_msg_is_masked
    e = ConfigError.gen(CONFIG_ERROR_CODE_1, :masked => true)
    assert(e.code == CONFIG_ERROR_CODE_1)
    assert(e.status == CONFIG_ERROR_STATUS_1)
    assert(e.msg == MY_MASKED_MSG)
    assert(!e.internal?)
  end

  def test_config_should_contain_the_info_if_an_info_is_given
    info = 'some information'
    e = ConfigError.gen(CONFIG_ERROR_CODE_1, :info => info)
    assert(e.info == info)
  end
end
