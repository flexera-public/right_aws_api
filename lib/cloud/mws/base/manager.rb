#--
# Copyright (c) 2013 RightScale, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require "cloud/mws/base/routines/request_signer"

module RightScale
  module CloudApi

    # MWS namespace
    module MWS

      # Thread safe parent class for almost all the MWS services.
      class Manager < CloudApi::Manager
      end

      # Thread un-safe parent class for almost all the MWS services.
      class ApiManager < AWS::ApiManager

        DEFAULT_API_VERSION = '2009-01-01'
        WMS_ENDPOINT        = 'https://mws.amazonservices.com/'
        WMS_SERVICE_PATH    = nil

        set_routine RetryManager
        set_routine RequestInitializer
        set_routine MWS::RequestSigner
        set_routine RequestGenerator
        set_routine RequestAnalyzer
        set_routine ConnectionProxy
        set_routine ResponseAnalyzer
        set_routine CacheValidator
        set_routine ResponseParser
        set_routine ResultWrapper

        def api(action, params={}, &block)
          params['Action'] ||= action.to_s._snake_case._camelize
          opts = {}
          verb           = params.delete(:verb) || :post
          opts[:body]    = params.delete(:body)
          opts[:headers] = params.delete(:headers) || {}
          opts[:options] = params.delete(:options) || {}
          opts[:params]  = parametrize(params)
          if self.class::WMS_SERVICE_PATH
            opts[:options][:cloud] ||= {}
            opts[:options][:cloud][:service_path] = self.class::WMS_SERVICE_PATH
          end
          process_api_request(verb, '', opts, &block)
        end

      end
    end
  end
end
