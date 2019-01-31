require_relative 'blockchain_verifier.rb'
require 'flamegraph'
require "fast_stack"

# if the wrong arguments are given, show them how its done
def show_usage_and_exit
  puts 'Usage:', 'verifier.rb *filename* file should be a blockchain.txt file'
  exit 1
end

# Returns true if and only if:
# 1. There is one and only one argument
# 2. The arguement is an existing file
# Returns false otherwise
def check_args(args)
  args.count == 1
  File.exist?(ARGV[0].to_s)
rescue StandardError
  false
end

Flamegraph.generate('verifier.html') do
  valid_args = check_args ARGV
  if valid_args
    bcv = BlockchainVerifier.new()
    bcv.verify(File.new(ARGV[0], "r"))
    exit
    #verify(ARGV[0])
  else
    show_usage_and_exit
  end
end

