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

require 'right_cloud_api_base'

$:.unshift(File::expand_path(File::dirname(__FILE__)))

require "right_aws_api_version"

require "cloud/aws/as/manager"
require "cloud/aws/cf/manager"
require "cloud/aws/cfm/manager"
require "cloud/aws/cw/manager"
require "cloud/aws/eb/manager"
require "cloud/aws/ec/manager"
require "cloud/aws/ec2/manager"
require "cloud/aws/elb/manager"
require "cloud/aws/emr/manager"
require "cloud/aws/iam/manager"
require "cloud/aws/rds/manager"
require "cloud/aws/route53/manager"
require "cloud/aws/s3/manager"
require "cloud/aws/sdb/manager"
require "cloud/aws/sns/manager"
require "cloud/aws/sqs/manager"