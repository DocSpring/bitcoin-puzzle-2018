# frozen_string_literal: true

class Integer
  def to_hex(bytes = 1)
    to_s(16).rjust(bytes * 2, '0')
  end
end
