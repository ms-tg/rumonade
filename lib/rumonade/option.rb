require 'singleton'
require 'rumonade/monad'

module Rumonade
  module Option
    def self.unit(value)
      Rumonade.Option(value)
    end

    def self.empty
      None
    end

    def self.included(mod)
      mod.send(:define_method, :unit) { |value| Rumonade::Option.unit(value) }
    end

    def bind(lam = nil, &blk)
      f = lam || blk
      empty? ? self : f[value]
    end

    include Monad

    def get
      if !empty? then value else raise NoSuchElementError end
    end

    def get_or_else(val_or_lam = nil, &blk)
      v_or_f = val_or_lam || blk
      if !empty? then value else (v_or_f.respond_to?(:call) ? v_or_f.call : v_or_f) end
    end

    def or_nil
      get rescue nil
    end
  end

  class Some
    include Option

    def initialize(value)
      @value = value
    end

    attr_reader :value

    def self.unit(value)
      Option.unit(value)
    end

    def empty?
      false
    end

    def ==(other)
      other.is_a?(Some) && other.value == value
    end

    def to_s
      "Some(#{value.to_s})"
    end
  end

  class NoneClass
    include Option
    include Singleton

    def empty?
      true
    end

    def ==(other)
      other.equal?(self.class.instance)
    end

    def to_s
      "None"
    end
  end

  class NoSuchElementError < RuntimeError; end

  def Option(value)
    value.nil? ? None : Some(value)
  end

  def Some(value)
    Some.new(value)
  end

  None = NoneClass.instance

  module_function :Option, :Some
  public :Option, :Some
end
