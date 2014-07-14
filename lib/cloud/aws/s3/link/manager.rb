#--
# Copyright (c) 2014 RightScale, Inc.
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

require "cloud/aws/s3/manager"
require "cloud/aws/s3/link/routines/request_signer"
require "cloud/aws/s3/link/wrappers/default"

module RightScale
  module CloudApi
    module AWS
      module S3

        # Simple Storage Service Query API link namespace
        #
        # @api public
        #
        module Link

          # S3 Query API links manager
          #
          # @example
          #   link = RightScale::CloudApi::AWS::S3::Link::Manager::new(key, secret, endpoint)
          #   link.get(
          #     'devs-us-east/kd/Константин',
          #     :params => { 'response-content-type' => 'image/peg'}
          #   ) #=>
          #     https://devs-us-east.s3.amazonaws.com/kd%2F%D0%9A%D0%BE%D0%BD%D1%81%D1%82%D0%B0%
          #     D0%BD%D1%82%D0%B8%D0%BD?AWSAccessKeyId=AK...TA&Expires=1436557118&
          #     Signature=hg...%3D&response-content-type=image%2Fpeg
          #
          # @example
          #   link.ListAllMyBuckets#=>
          #     https://s3.amazonaws.com/?AWSAccessKeyId=AK...TA&Expires=1436651780&
          #     Signature=XK...53s%3D
          #
          class Manager < S3::Manager
          end

          class ApiManager < S3::ApiManager
            set_routine CloudApi::RequestInitializer
            set_routine AWS::S3::Link::RequestSigner

            include Mixin::QueryApiPatterns
          end
        end

      end
    end
  end
end