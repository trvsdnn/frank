module FrankHelpers
  def hello_helper
    'hello from helper'
  end

  def title(val = nil)
    @title = val if val
    @title || ""
  end
end