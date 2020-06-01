require 'rspec'
class Memory
  def initialize(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
    @hash_value = hash_value
    @hash_flag = hash_flag
    @hash_exptime = hash_exptime
    @hash_bytes = hash_bytes
    @hash_token = hash_token
    @hash_date = hash_date
  end

  def hash_value
    @hash_value
  end

  def hash_bytes
    @hash_bytes
  end

  def hash_token
    @hash_token
  end

  def hash_date
    @hash_date
  end

  def hash_exptime
    @hash_exptime
  end

  def hash_flag
    @hash_flag
  end

  def asign_data(key,value,bytes,flag,exptime)
    @hash_value["#{key}"] = value
    @hash_flag["#{key}"] = flag
    @hash_exptime["#{key}"] = exptime
    @hash_bytes["#{key}"] = bytes
    @hash_date["#{key}"] = Time.now
  end

  def delete_data(key)
    @hash_value.delete(key)
    @hash_token.delete(key)
    @hash_date.delete(key)
    @hash_exptime.delete(key)
    @hash_bytes.delete(key)
    @hash_flag.delete(key)
  end
end



describe Memory do

    it 'verify if data is correct saved' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"value","bytes","flag","exptime")
      validate = true
      expect(memory.hash_value.has_key?(key)).to eq validate
      expect(memory.hash_flag.has_key?(key)).to eq validate
      expect(memory.hash_date.has_key?(key)).to eq validate
      expect(memory.hash_bytes.has_key?(key)).to eq validate
      expect(memory.hash_exptime.has_key?(key)).to eq validate
    end

    it 'verify if data is correct saved' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"value","bytes","flag","exptime")
      validate = true
      expect(memory.hash_value["#{key}"] == "value").to eq validate
      expect(memory.hash_flag["#{key}"] == "flag").to eq validate
      expect(memory.hash_date["#{key}"] == Time.now).to eq validate
      expect(memory.hash_bytes["#{key}"] == "bytes").to eq validate
      expect(memory.hash_exptime["#{key}"] == "exptime").to eq validate
    end

    it 'verify if data is correct deleted' do
      hash_value = Hash.new
      hash_flag = Hash.new
      hash_exptime = Hash.new
      hash_bytes = Hash.new
      hash_token = Hash.new
      hash_date = Hash.new
      memory = Memory.new(hash_value,hash_flag,hash_exptime,hash_bytes,hash_token,hash_date)
      key = "key"
      memory.asign_data(key,"value","bytes","flag","exptime")
      memory.delete_data(key)
      validate = false
      expect(memory.hash_value.has_key?(key)).to eq validate
      expect(memory.hash_flag.has_key?(key)).to eq validate
      expect(memory.hash_date.has_key?(key)).to eq validate
      expect(memory.hash_bytes.has_key?(key)).to eq validate
      expect(memory.hash_exptime.has_key?(key)).to eq validate
    end

end