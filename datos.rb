class Datos
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