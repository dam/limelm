module LimeLm
  class Utils
    def self.stringify_keys(hash)
      Hash[hash.map{ |k, v| [k.to_s, v] }]
    end
  end
end