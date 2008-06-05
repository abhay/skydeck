class Hash
  def to_qs
    map{|i|"#{i[0]}=#{i[1]}"}.join("&")
  end
end