#--
# Copyright (c) 2016 RightScale, Inc.
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

module RightScale
  module CloudApi
    module Parser
      module AWS

        # AWS Support Parsers namespace
        module Support

          # AWS Support response error
          class ResponseError

            # Parses HTTP error message from a response body
            #
            # @param [RightScale::CloudApi::HttpResponse] response
            # @param [Hash] options
            # @option options [Object] :xml_parser
            #
            # @return [String] to be displayed/logged.
            #
            # @example
            #    {"__type":"UnknownOperationException"}
            #
            def self.parse(response, options={})
              body   = response.body.to_s
              result = "#{response.code}"

              unless body._blank?
                if response['content-type'].to_s[/json/]
                  type = ::JSON::parse(body)["__type"]
                  result << ": #{type}"
                else
                  result << ": #{body}"
                end
              end
              result
            end
          end

        end
      end
    end
  end
end
