# Code Error

A code-based customized error.

[![Gem Version](https://badge.fury.io/rb/code_error.png)][gem]

[gem]: https://rubygems.org/gems/code_error

    raise MyError.new(:wrong_format)

## Why?

It is a standard error but it provides more.

* All error cases are defined in the same place. Easy to find and reference.
* Just raising an error with a code, then the corresponding status and message are ready to use.
* Highly customizable and extendable, you can even re-define the default messages to what you want.

## Usage

### Basic

Inherit CodeError::Base to create your own code-based error. You need to assign "error_codes" with a hash to define your own error code map.

    class MyError < CodeError::Base

      error_codes {
        purchase_info_incorrect: {
          status: :failed,
          msg: 'Purchase information format is incorrect.'
        },
        device_info_incorrect: {
          status: :failed,
          msg: 'Device information format is incorrect.'
        },
        unknown_store: {
          status: :failed,
          msg: 'Unknown store.'
        },
        duplicated_request: {
          status: :duplicated,
          msg: 'A duplicated IAP request is sent.'
        },
        resend_iap: {
          status: :retry,
          msg: 'Client should send the IAP request again.'
        }
      }

    end

Raise an error with a code when you need.

    raise MyError.new(:purchase_info_incorrect)

Rescue and handle it.

    begin
      #...
      raise MyError.new(:purchase_info_incorrect)
      #...
    rescue MyError => e
      raise e if e.internal?
      msg = e.msg
      code = e.code
      info = e.info
      data = e.data
      case(e.status)
      when :failed
        #...
      when :duplicated
        #...
      else
        #...
      end
      #...
    end

#### Customize error code hash

A customized code-based error class need to assign the "error_codes" method with a hash like:

    error_codes {
      purchase_info_incorrect: {
        status: :failed,
        msg: 'Purchase information format is incorrect.'
      },
      device_info_incorrect: {
        status: :failed,
        msg: 'Device information format is incorrect.'
      },
      unknown_store: {
        status: :failed,
        msg: 'Unknown store.',
        masked: true
      },
      duplicated_request: {
        status: :duplicated,
        msg: 'A duplicated IAP request is sent.',
        masked: true
      },
      resend_iap: {
        status: :retry,
        msg: 'Client should send the IAP request again.'
      }
    }

where the hash key is the supported code which can be a symbol, string or number and the hash value is an another hash to store the code information corresponding each codes. The code information hash contains the following keys:

* :status - [any type you like] The error status to define the error handling flow. You can get it by calling the "status" method.
* :msg - [String] The error message. You can get it by calling the "msg" method.
* :masked - (optional)[Boolean] To define the error message is masked by default or not. The default value is false if no `:masked` is given.

#### Raise a code-based error

Once you setup the error codes, raising a code-based error is easy.

    raise MyError.new(:purchase_info_incorrect)

There are three argments in the code error constructor, `MyError.new(code, msg, info)`. If the given code is defined in the error_codes, the error would contain the corresponding status and msg.

    e = MyError.new(:purchase_info_incorrect)
    e.code # :purchase_info_incorrect
    e.status # :failed
    e.msg # "Purchase information format is incorrect."

You can give another string in "msg" arg to overwrite the original message:

    e = MyError.new(:purchase_info_incorrect, "The another message which would override the original one.")
    e.code # :purchase_info_incorrect
    e.status # :failed
    e.msg # "The another message which would override the original one."

If the given code is unknown, the error would become an internal error, i.e., the status is the `:internal` status.

    e = MyError.new(:unknown_error)
    e.code # :unknown_error
    e.status # :internal
    e.msg # "An internal error occurs."
    e.internal? # true

If a string is given, the error is also an internal error, but the "msg" would keep this string.

    e = MyError.new("Invalid input!!")
    e.code # :internal_error
    e.status # :internal
    e.msg # "Invalid input!!"
    e.internal? # true

You can pass anything to the error handling you want through the "info" arg.

    something = 'what you want...'
    e = MyError.new(:purchase_info_incorrect, nil, something)
    e.info # 'what you want...'

There is a special code `:success` which used in the success case.

    e = MyError.new(:success)
    e.code # :success
    e.status # :success
    e.msg # ""
    e.internal? # false

#### Handle the code-base error

When you rescue a code-based error, some useful methods are ready to use.

* code - The error code
* status - The error status
* msg - The error message
* info - The error information
* data - A hash contains the values of code, status, msg, info.
* internal? - To show this error is an internal error or not.

Here is an example:

    e = MyError.new(:purchase_info_incorrect, nil, 'some information')
    e.code # :purchase_info_incorrect
    e.status # :failed
    e.msg # "Purchase information format is incorrect."
    e.info # "some information"
    e.data # { code: :purchase_info_incorrect, status: :failed, msg: "Purchase information format is incorrect.(20001)", info: 'some information' }
    e.internal? # false

### Configure your code-base error

You can customize the default behavior in your code-based error. Here is an example:

    class MyError < CodeError::Base

      error_codes {
        #...
      }

      success_config {
        code: :ok,
        status: :success,
        msg: "My success message."
      }

      internal_config {
        code: :oops,
        status: :failed,
        msg: "My internal error message."
      }

      masked_msg "My masked message."

    end

where the configures are:

* success_config - [Hash] Define the success code, status and message. The default value is `{ code: CodeError::SUCCESS_CODE, status: CodeError::SUCCESS_STATUS, msg: "" }`.
* internal_config - [Hash] Define the internal error code, status and message. The default value is `{ code: CodeError::INTERNAL_CODE, status: CodeError::INTERNAL_STATUS, msg: "" }`.
* masked_msg - [String] Define the message to replace the masked one. The default value is `CodeError::MASKED_MSG`.

#### Mask the error message

You can mask an error message if you don't want to show it. A masked message would be replaced with the default masked message. There are several ways to do it, they are listed below sorted by the precedence.

* Pass `true` to the "masked" arg in the "msg" or "data" method.

    e = MyError.new(:purchase_info_incorrect)
    e.msg(ture) # "An error occurs."
    e.data(true) # { code: :purchase_info_incorrect, status: :failed, msg: "An error occurs.", info: {} }

* Pass the `:masked` to the "msg" arg in the "new" method.

    e = MyError.new(:purchase_info_incorrect, :masked)
    e.msg # "An error occurs."

* Add `masked: true` in the error_codes hash for particular error. Please see [Customize error code hash].

The default masked message can be customized to your own message by overwriting the `:masked_msg` in your config hash. Please see [Configure your code-base error].

## Test

Go to code_error gem folder and run

    ruby ./test/test_all.rb

## Authors

Sibevin Wang

## Copyright

Copyright (c) 2013 - 2014 Sibevin Wang. Released under the MIT license.
