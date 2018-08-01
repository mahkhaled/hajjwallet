# encoding: utf-8

require 'money'

module Spree
  class Money
    class <<self
      attr_accessor :default_formatting_rules
    end
    self.default_formatting_rules = {
      # Ruby money currently has this as false, which is wrong for the vast
      # majority of locales.
      sign_before_symbol: true
    }

    attr_reader :money

    delegate :cents, :currency, to: :money

    def initialize(amount, options = {})
      @money = Monetize.parse([amount, (options[:currency] || Spree::Config[:currency])].join)
      @options = Spree::Money.default_formatting_rules.merge(options)
    end

    def amount_in_cents
      (cents / currency.subunit_to_unit.to_f * 100).round
    end

    def to_s
      @money.format(@options)
    end

    def to_html(options = { html: true })
      output = @money.format(@options.merge(options))
      if options[:html]
        # 1) prevent blank, breaking spaces
        # 2) prevent escaping of HTML character entities
        output = output.sub(' ', '&nbsp;').html_safe
      end
      output
    end

    def as_json(*)
      to_s
    end

    def decimal_mark
      return @money.decimal_mark if @options[:decimal_mark].nil?
      @options[:decimal_mark]
    end

    def thousands_separator
      return @money.thousands_separator if @options[:thousands_separator].nil?
      @options[:thousands_separator]
    end

    def ==(obj)
      @money == obj.money
    end
  end
end
